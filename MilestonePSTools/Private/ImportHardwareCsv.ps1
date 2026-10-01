# Copyright 2025 Milestone Systems A/S
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function ImportHardwareCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Path,
        
        [Parameter()]
        [VideoOS.Platform.ConfigurationItems.RecordingServer]
        $RecordingServer,

        [Parameter()]
        [pscredential[]]
        $Credential,

        [Parameter()]
        [switch]
        $UpdateExisting,

        [Parameter()]
        [char]
        $Delimiter = ','
    )

    process {
        $progress = @{
            Id               = 1
            Activity         = 'Import hardware from CSV'
            Status           = 'Loading CSV file'
            PercentComplete  = 0
            CurrentOperation = ''
        }
        Write-Progress @progress
        # Read CSV file, perform basic validation, and normalize records
        $rows = Import-Csv -LiteralPath $Path -Delimiter $Delimiter
        if ($RecordingServer) {
            $rows | ForEach-Object {
                if (-not [string]::IsNullOrWhiteSpace($_.RecordingServer)) {
                    $_.RecordingServer = $RecordingServer.Name
                }
            }
        }
        $records = [pscustomobject[]](ValidateHardwareCsvRows -Rows $rows)
        $recordsProcessed = 0
        $progressStopwatch = [diagnostics.stopwatch]::StartNew()

        # Set RecordingServer property on all records to match RecordingServer parameter if provided.
        # Warn user that the RecordingServer from the CSV, if present, will be ignored.
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('RecordingServer')) {
            for ($i = 0; $i -lt $records.Count; $i++) {
                if (-not [string]::IsNullOrWhiteSpace($records[$i].RecordingServer) -and $records[$i].RecordingServer -ne $RecordingServer.Name) {
                    Write-Warning "Ignoring RecordingServer value in row $($i + 1) in favor of `"$($RecordingServer.Name)`""
                }
                $records[$i].RecordingServer = $RecordingServer.Name
            }
        }

        # Check if there are any duplicate device entries
        $duplicateDevices = $records | Group-Object { "$($_.RecordingServer).$($_.Address).$($_.DeviceType).$($_.Channel)" } | Where-Object Count -GT 1
        if ($duplicateDevices) {
            Write-Error -Message 'Duplicate device records found. Please ensure there are no rows with identical values for RecordingServer, Address, DeviceType, and Channel.' -TargetObject $duplicateDevices -Category InvalidData -ErrorId 'DuplicateDeviceRecord'
            return
        }

        $recordsByRecorder = $records | Group-Object RecordingServer
        $recorders = @{}
        Get-VmsRecordingServer | Where-Object Name -In $recordsByRecorder.Name | ForEach-Object {
            $recorders[$_.Name] = $_
        }
        try {
            foreach ($recorderGroup in $recordsByRecorder) {
                $progress.Status = "Processing $($recorderGroup.Count) records for recording server $($recorderGroup.Name)"
                Write-Progress @progress
                # Abort if no Recording Server was specified in CSV file or in RecordingServer argument.
                if ([string]::IsNullOrWhiteSpace($recorderGroup.Name)) {
                    $recorderGroup.Group | ForEach-Object {
                        $_.Result += 'RecordingServer not specified.'
                    }
                    Write-Error -Message "RecordingServer not specified. Specify the destination recording server using the RecordingServer parameter, or add a RecordingServer column to your CSV file with the display name of the destination recording server. This affects $($recorderGroup.Count) rows in the file `"$Path`"."
                    continue
                }
    
                # Abort if the specified recording server is not found
                $recorder = $recorders[$recorderGroup.Name]
                if ($null -eq $recorder) {
                    $recorderGroup.Group | ForEach-Object {
                        $_.Result += 'RecordingServer not found.'
                    }
                    Write-Error -Message "RecordingServer with display name `"$($recorderGroup.Name)`" not found. This affects $($recorderGroup.Count) rows in the file `"$Path`"."
                    continue
                }
    
                # Check for unrecognized StorageName values
                $existingStorage = @{}
                $recorder | Get-VmsStorage | ForEach-Object {
                    $existingStorage[$_.Name] = $_
                }
                foreach ($storageGroup in $recorderGroup.Group | Group-Object StorageName | Where-Object { -not [string]::IsNullOrWhiteSpace($_.Name) }) {
                    if (!$existingStorage.ContainsKey($storageGroup.Name)) {
                        Write-Error -Message "Storage with display name `"$($storageGroup.Name)`" not found. This affects $($storageGroup.Count) rows in the file `"$Path`"."
                    }
                }
    
                $progress.CurrentOperation = "Getting existing hardware and available drivers"
                Write-Progress @progress
    
                # Cache hardware already present
                $recorder.HardwareFolder.ClearChildrenCache()
                $existingHardware = @{}
                $recorder | Get-VmsHardware | ForEach-Object {
                    $existingHardware[([uribuilder]$_.Address).Uri.GetComponents([uricomponents]::SchemeAndServer, [uriformat]::SafeUnescaped)] = $_
                }
    
                $availableDrivers = $recorder | Get-VmsHardwareDriver -ErrorAction Stop
                $progress.CurrentOperation = ''
                Write-Progress @progress

                # Only perform express scan if at least one row for this recording server lacks a DriverNumber value
                $executeExpressScan = $null -ne ($recorderGroup.Group | Where-Object { $_.DriverNumber -eq 0 -and !$existingHardware.Contains($_.Address)})
                $expressScanResults = @{}
                if ($executeExpressScan) {
                    $progress.CurrentOperation = "Running Start-VmsHardwareScan -Express"
                    Write-Progress @progress
                    $expressScanSplat = @{
                        Express               = $true
                        UseDefaultCredentials = $true
                    }
    
                    # Build a group of credentials from the Credential parameter if provided, and a collection of unique
                    # credentials provided for devices on this recorder in the CSV file.
                    $expressCredentials = [collections.generic.list[pscredential]]::new()
                    $Credential | ForEach-Object {
                        if ($null -ne $_) {
                            $expressCredentials.Add($_)
                        }
                    }
                    $recorderGroup.Group | Where-Object {
                        ![string]::IsNullOrWhiteSpace($_.UserName) -and ![string]::IsNullOrWhiteSpace($_.Password)
                    } | Group-Object { 
                        '{0}:{1}' -f $_.UserName, $_.Password 
                    } | ForEach-Object {
                        $expressCredentials.Add([pscredential]::new($_.Group[0].UserName, ($_.Group[0].Password | ConvertTo-SecureString -AsPlainText -Force)))
                    }
                    if ($expressCredentials.Count -gt 0) {
                        $expressScanSplat.Credential = $expressCredentials
                    }
                    $recorder | Start-VmsHardwareScan @expressScanSplat -Verbose:$false -ErrorAction SilentlyContinue | Where-Object HardwareScanValidated | ForEach-Object {
                        $uri = ([uribuilder]$_.HardwareAddress).Uri.GetComponents([uricomponents]::SchemeAndServer, [uriformat]::SafeUnescaped)
                        $expressScanResults[$uri] = $_
                    }
                }
    
                $recordsByHardware = $recorderGroup.Group | Group-Object Address
                foreach ($hardwareGroup in $recordsByHardware) {
                    $recordsProcessed += $hardwareGroup.Count
                    $progress.PercentComplete = $recordsProcessed / $records.Count * 100
                    $completedRecords = [math]::Max(($recordsProcessed - $hardwareGroup.Count), 0)
                    if ($completedRecords -gt 0 -and $records.Count -gt 0) {
                        $timePerRecord = $progressStopwatch.ElapsedMilliseconds / $completedRecords
                        $remainingRecords = $records.Count - $completedRecords
                        $remainingTime = [timespan]::FromMilliseconds($remainingRecords * $timePerRecord)
                        $progress.SecondsRemaining = [int]$remainingTime.TotalSeconds
                    } else {
                        $progress.Remove('SecondsRemaining')
                    }
                    Write-Progress @progress

                    # If hardware already exists, update DriverNumber for related CSV records
                    if ($existingHardware.ContainsKey($hardwareGroup.Name)) {
                        $currentDriver = $existingHardware[$hardwareGroup.Name] | Get-VmsHardwareDriver
                        if ($currentDriver.Number -ne $hardwareGroup.Group[0].DriverNumber) {
                            $hardwareGroup.Group | ForEach-Object {
                                $_.DriverNumber = $currentDriver.Number
                            }
                        }
                    }
                    $driver = ($availableDrivers | Where-Object Number -EQ $hardwareGroup.Group[0].DriverNumber).Path
                    if ($null -eq $driver) {
                        # Discover driver via hardware scans - first check express scan results, then do targetted scan.
                        if ($expressScanResults[$hardwareGroup.Name]) {
                            $driver = $expressScanResults[$hardwareGroup.Name].HardwareDriverPath
                            $hardwareGroup.Group[0].UserName = $expressScanResults[$hardwareGroup.Name].UserName
                            $hardwareGroup.Group[0].Password = $expressScanResults[$hardwareGroup.Name].Password
                            $hardwareGroup.Group | ForEach-Object {
                                $_.DriverNumber = ($availableDrivers | Where-Object Path -eq $driver).Number
                            }
                            Write-Verbose "Adding $($hardwareGroup.Name) to $($recorder.Name) using DriverNumber $(($availableDrivers | Where-Object Path -EQ $driver).Number) discovered during express scan."
                        } else {
                            $progress.CurrentOperation = "Trying to determine the correct driver for $($hardwareGroup.Name)"
                            Write-Progress @progress
    
                            # Hardware not found in express scan. Perform targetted scan on hardware address
                            $scanSplat = @{
                                Address               = $hardwareGroup.Name
                                UseDefaultCredentials = $true
                                Credential            = [collections.generic.list[pscredential]]::new()
                            }
                            if (-not [string]::IsNullOrWhiteSpace($hardwareGroup.Group[0].DriverGroup)) {
                                $scanSplat.DriverFamily = $hardwareGroup.Group[0].DriverGroup -split ';' | Where-Object {
                                    -not [string]::IsNullOrWhiteSpace($_)
                                } | ForEach-Object { $_.Trim() }
                            }
    
                            # Build credential set for hardware scan using credentials from row if available along with
                            # credentials provided using the Credential parameter.
                            if (![string]::IsNullOrWhiteSpace($hardwareGroup.Group[0].UserName) -and ![string]::IsNullOrWhiteSpace($hardwareGroup.Group[0].Password)) {
                                $scanSplat.Credential.Add([pscredential]::new($hardwareGroup.Group[0].UserName, ($hardwareGroup.Group[0].Password | ConvertTo-SecureString -AsPlainText -Force)))
                            }
                            $Credential | ForEach-Object {
                                if ($null -ne $_) {
                                    $scanSplat.Credential.Add($_)
                                }
                            }
                            
                            # Perform targetted hardware scan. Multiple scans may be performed depending on the number of credentials provided
                            # so return the first validated scan.
                            $hardwareScan = $recorder | Start-VmsHardwareScan @scanSplat -Verbose:$false | Where-Object HardwareScanValidated | Select-Object -First 1
                            if ($hardwareScan.HardwareScanValidated) {
                                $driver = $hardwareScan.HardwareDriverPath
                                $hardwareGroup.Group[0].UserName = $hardwareScan.UserName
                                $hardwareGroup.Group[0].Password = $hardwareScan.Password
                            } else {
                                Write-Error "Hardware scan was unsuccessful for $($hardwareGroup.Name) on RecordingServer $($recorder.Name). Check the provided credentials, and driver, and try again." -Category InvalidResult -ErrorId 'AddHardwareFailed' -TargetObject $hardwareGroup.Group
                                $hardwareGroup.Group | ForEach-Object {
                                    $_.Result += "Failed to detect the correct driver for the hardware based on the provided credential(s), and DriverGroup. Note that a small number of drivers do not support hardware scanning and the exact driver is required."
                                }
                                continue
                            }
                        }
                    }
                    if ($null -eq $driver) {
                        $hardwareGroup.Group | ForEach-Object {
                            $_.Result += 'DriverNumber not found on RecordingServer.'
                        }
                        Write-Error -Message "No hardware driver found for device at $($hardwareGroup.Name) with DriverNumber $($hardwareGroup.Group[0].DriverNumber) on RecordingServer $($recorder.Name)." -TargetObject $hardwareGroup.Group
                        continue
                    }
                    $recordsByDeviceType = $hardwareGroup.Group | Group-Object DeviceType
                    $skipHardware = $false
                    foreach ($deviceTypeGroup in $recordsByDeviceType) {
                        $invalidDeviceTypeGroup = $deviceTypeGroup.Group | Group-Object Channel | Where-Object Count -GT 1
                        if ($invalidDeviceTypeGroup) {
                            $skipHardware = $true
                            $hardwareGroup.Group | ForEach-Object {
                                $_.Result += 'One or more devices with this Address have the same DeviceType and Channel.'
                            }
                            Write-Error -Message "Multiple $($deviceTypeGroup.Name) records found for $($hardwareGroup.Name) with the same channel number. Please add, or correct the Channel field in your CSV file." -TargetObject $invalidDeviceTypeGroup.Group
                        }
                    }
                    if ($skipHardware) {
                        continue
                    }
    
                    try {
                        $hwSplat = @{
                            Enabled  = $true
                            PassThru = $true
                        }
    
                        if (-not [string]::IsNullOrWhiteSpace($hardwareGroup.Group[0].HardwareName)) {
                            $hwSplat.Name = $hardwareGroup.Group[0].HardwareName
                        }
                        if (-not [string]::IsNullOrWhiteSpace($hardwareGroup.Group[0].UserName)) {
                            $hwSplat.UserName = $hardwareGroup.Group[0].UserName
                        }
                        if (-not [string]::IsNullOrWhiteSpace($hardwareGroup.Group[0].Password)) {
                            $hwSplat.Password = $hardwareGroup.Group[0].Password | ConvertTo-SecureString -AsPlainText -Force
                        }
    
                        if ($existingHardware.ContainsKey($hardwareGroup.Name)) {
                            if (-not $UpdateExisting) {
                                Write-Verbose "Skipping row(s) $($hardwareGroup.Group.Row -join ', ') because the hardware is already added and the UpdateExisting parameter was omitted."
                                $hardwareGroup.Group | ForEach-Object {
                                    $_.Result += 'Skipped because the hardware already exists and -UpdateExisting was not used.'
                                    $_.Path = ($existingHardware[$hardwareGroup.Name] | Get-VmsDevice -Type $_.DeviceType -Channel $_.Channel).Path
                                }
                                continue
                            }
                            Write-Verbose "Updating existing device(s) for hardware at $($hardwareGroup.Name) defined in row(s) $($hardwareGroup.Group.Row -join ', ')"
                            $hardwareGroup.Group | ForEach-Object { $_.Result += 'Updating existing hardware.' }
                            $hardware = $existingHardware[$hardwareGroup.Name]
                        } else {
                            $skipHardware = $true
                            $credentials = [collections.generic.list[pscredential[]]]::new()
                            if (-not [string]::IsNullOrWhiteSpace($hardwareGroup.Group[0].UserName) -and -not [string]::IsNullOrWhiteSpace($hardwareGroup.Group[0].Password)) {
                                $credentials.Add([pscredential]::new($hardwareGroup.Group[0].UserName, ($hardwareGroup.Group[0].Password | ConvertTo-SecureString -AsPlainText -Force)))
                            }
                            foreach ($c in $Credential) {
                                $credentials.Add($c)
                            }
                            if ($credentials.Count -eq 0) {
                                $hardwareGroup.Group | ForEach-Object {
                                    $_.Result += "Hardware not added - no credentials provided."
                                }
                                Write-Warning "Skipping $($hardware.Name) as no credentials have been provided."
                            }
                            for ($credIndex = 0; $credIndex -lt $credentials.Count; $credIndex++) {
                                $cred = $credentials[$credIndex]
                                try {
                                    $progress.CurrentOperation = "Adding $($hardwareGroup.Name)"
                                    Write-Progress @progress
                                    $task = $recorder.AddHardware($hardwareGroup.Name, $driver, $cred.UserName, $cred.Password, $null) | Wait-VmsTask -Cleanup
                                    if (($task.Properties | Where-Object Key -EQ 'State').Value -eq 'Error') {
                                        if ($credIndex -ge $credentials.Count - 1) {
                                            $hardwareGroup.Group | ForEach-Object { $_.Result += 'Failed to add hardware.' }
                                            Write-Error -Message "Failed to add $($hardwareGroup.Name) in row(s) $($hardwareGroup.Group.Row -join ', ') to RecordingServer $($recorder.Name): $(($task.Properties | Where-Object Key -EQ 'ErrorText').Value)" -Category InvalidResult -ErrorId 'AddHardwareFailure' -TargetObject $hardwareGroup.Group
                                            break
                                        } else {
                                            Write-Warning "Failed to add $($hardwareGroup.Name) in row(s) $($hardwareGroup.Group.Row -join ', ') to RecordingServer $($recorder.Name). Retrying with another credential..."
                                        }
                                        continue
                                    } else {
                                        
                                        $skipHardware = $false
                                        break
                                    }
                                } catch {
                                    throw
                                }
                            }
                            if ($skipHardware) {
                                $hardwareGroup.Group | ForEach-Object {
                                    $_.Result += 'Hardware successfully added.'
                                }
                                continue
                            } else {
                                $hardwareGroup.Group | ForEach-Object {
                                    $_.Result += 'Hardware successfully added.'
                                }
                            }
    
                            $hardware = [VideoOS.Platform.ConfigurationItems.Hardware]::new($recorder.ServerId, ($task.Properties | Where-Object Key -EQ 'Path').Value)
                            'UserName', 'Password' | ForEach-Object {
                                if ($hwSplat.ContainsKey($_)) { $hwSplat.Remove($_) }
                            }
                        }
                        $hardware = $hardware | Set-VmsHardware @hwSplat
                        
                        $progress.CurrentOperation = "Updating settings for $($hardwareGroup.Count) devices on $($hardwareGroup.Name)"
                        Write-Progress @progress
                        foreach ($deviceRecord in $hardwareGroup.Group) {
                            $splat = @{
                                Enabled = $deviceRecord.Enabled
                            }
                            if (-not [string]::IsNullOrWhiteSpace($deviceRecord.Name)) {
                                $splat.Name = $deviceRecord.Name
                            }
                            if (-not [string]::IsNullOrWhiteSpace($deviceRecord.Coordinates)) {
                                $splat.Coordinates = $deviceRecord.Coordinates
                            }
                            
                            $device = $hardware | Get-VmsDevice -Type $deviceRecord.DeviceType -Channel $deviceRecord.Channel -EnableFilter All
                            if ($null -eq $device) {
                                Write-Error "$($deviceRecord.DeviceType) channel $($deviceRecord.Channel) not found on hardware with address $($hardwareGroup.Name) on RecordingServer $($recorder.Name) defined in row $($deviceRecord.Row)."
                                $deviceRecord.Result += 'Channel does not exist on hardware.'
                                continue
                            }
                            $deviceRecord.Path = $device.Path
                            $device | Set-VmsDevice @splat
                            $deviceRecord.DeviceGroups -split ';' | ForEach-Object {
                                if ([string]::IsNullOrWhiteSpace($_)) { return }
                                $deviceGroup = New-VmsDeviceGroup -Type $deviceRecord.DeviceType -Path $_.Trim()
                                $deviceGroup | Add-VmsDeviceGroupMember -Device $device -ErrorAction SilentlyContinue
                            }
    
                            if ($device.RecordingStorage -and -not [string]::IsNullOrWhiteSpace($deviceRecord.StorageName)) {
                                if ($existingStorage.ContainsKey($deviceRecord.StorageName)) {
                                    if ($device.RecordingStorage -ne $existingStorage[$deviceRecord.StorageName].Path) {
                                        $tries = 0
                                        $maxTries = 5
                                        $delay = [timespan]::FromSeconds(10)
                                        do {
                                            try {
                                                $device | Set-VmsDeviceStorage -Destination $deviceRecord.StorageName -ErrorAction Stop
                                                break
                                            } catch {
                                                $tries += 1
                                                if ($tries -ge $maxTries) {
                                                    $deviceRecord.Result += 'Failed to assign device to the specified storage.'
                                                    Write-Error -Message "Failed to assign $($deviceRecord.DeviceType) `"$($deviceRecord.Name)`" with address $($deviceRecord.Address) to storage `"$($deviceRecord.StorageName)`". $($_.Exception.Message)" -Exception $_.Exception -Category InvalidResult -ErrorId 'StorageAssignmentFailed' -TargetObject $deviceRecord
                                                } else {
                                                    Write-Warning "Failed to assign $($deviceRecord.DeviceType) `"$($deviceRecord.Name)`" with address $($deviceRecord.Address) to storage `"$($deviceRecord.StorageName)`". Attempt $tries of $maxTries. Retrying in $($delay.Seconds) seconds. $($_.Exception.Message)"
                                                    Start-Sleep -Seconds $delay.Seconds
                                                }
                                            }
                                        } while ($tries -lt $maxTries)
                                    }
                                } else {
                                    $storageGroup.Group | ForEach-Object {
                                        $_.Result += 'StorageName not found.'
                                    }
                                    Write-Warning "Cannot update the storage configuration for $($deviceRecord.Name) at $($hardware.Address) because StorageName $($deviceRecord.StorageName) does not exist on RecordingServer $($recorder.Name)."
                                }
                            }
                        }
                    } catch {
                        throw $_
                    }
                }
                $recorder.HardwareFolder.ClearChildrenCache()
            }
        } finally {
            $progress.Completed = $true
            Write-Progress @progress
        }
        $records
    }
}
