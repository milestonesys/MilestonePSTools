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

function ValidateHardwareCsvRows {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject[]]
        $Rows
    )

    process {
        $ErrorActionPreference = 'Stop'
        $defaultValues = @{
            DeviceType      = 'Camera'
            Name            = $null
            Address         = $null
            Channel         = 0
            UserName        = $null
            Password        = $null
            RecordingServer = $null
            DriverNumber    = 0
            DriverGroup     = $null
            Enabled         = $true
            StorageName     = $null
            HardwareName    = $null
            Coordinates     = $null
            DeviceGroups    = '/Imported from CSV'
            Path            = $null
            Result          = [string]::Empty
        }

        $supportedValues = @{
            DeviceType = @('Camera', 'Microphone', 'Speaker', 'Metadata', 'Input', 'Output')
        }

        for ($i = 0; $i -lt $Rows.Count; $i++) {
            $row = $Rows[$i]

            $record = [pscustomobject]@{
                Row             = $i + 1
                DeviceType      = $defaultValues['DeviceType']
                Name            = $defaultValues['Name']
                Address         = $defaultValues['Address']
                Channel         = $defaultValues['Channel']
                UserName        = $defaultValues['UserName']
                Password        = $defaultValues['Password']
                RecordingServer = $defaultValues['RecordingServer']
                DriverNumber    = $defaultValues['DriverNumber']
                DriverGroup    = $defaultValues['DriverGroup']
                Enabled         = $defaultValues['Enabled']
                StorageName     = $defaultValues['StorageName']
                HardwareName    = $defaultValues['HardwareName']
                Coordinates     = $defaultValues['Coordinates']
                DeviceGroups    = $defaultValues['DeviceGroups']
                Path            = $defaultValues['Path']
                Result          = $defaultValues['Result']
            }
            
            $headersProvided = ($row | Get-Member -MemberType NoteProperty).Name
            foreach ($property in $headersProvided) {
                if (-not $defaultValues.ContainsKey($property)) {
                    Write-Warning "Ignoring unsupported header `"$property`""
                    continue
                }
                if ($property -in @('Path', 'Result')) {
                    continue
                }
                $record.$property = $row.$property
            }
            $recorders = @{}
            $storages = @{}
            $driversByRecorder = @{}
            foreach ($recorder in Get-VmsRecordingServer) {
                $recorders[$recorder.Name] = $recorder
                foreach ($storage in $recorder | Get-VmsStorage) {
                    $storages["$($recorder.Name).$($storage.Name)"] = $null
                }
                foreach ($driver in $recorder | Get-VmsHardwareDriver) {
                    $driversByRecorder["$($recorder.Name).$($driver.Number)"] = $null
                }
            }
            foreach ($property in ($record | Get-Member -MemberType NoteProperty).Name) {
                switch ($property) {
                    'DeviceType' {
                        if ($record.DeviceType -notin $supportedValues.DeviceType) {
                            Write-Error -Message "Invalid DeviceType value `"$($row.DeviceType)`" in row $($i + 1). Supported values are $($supportedValues.DeviceType -join ', ')." -Category InvalidData -ErrorId "InvalidValue" -TargetObject $row
                        }
                    }
                    'Name' {}
                    'Address' {
                        try {
                            $record.Address = ([uribuilder]$record.Address).Uri.GetComponents([uricomponents]::SchemeAndServer, [uriformat]::SafeUnescaped)
                            if ($record.Address -notmatch '^https?') {
                                throw [argumentexception]::new("Invalid address scheme. Supported schemes are http and https.")
                            }
                        } catch {
                            $errorParams = @{
                                Message      = 'Invalid Address value "{0}" in row {0}.' -f $row.Address, ($i + 1)
                                Category     = 'InvalidData'
                                ErrorId      = 'InvalidValue'
                                TargetObject = $row
                            }
                            if ($null -ne $_.Exception) {
                                $errorParams.Exception = $_.Exception
                            }
                            Write-Error @errorParams
                        }
                    }
                    'Channel' {
                        $channelNumber = 0
                        if (-not [int]::TryParse($record.Channel, [ref]$channelNumber)) {
                            Write-Error -Message "Invalid Channel value `"$($row.Channel)`" in row $($i + 1)." -Category InvalidData -ErrorId "InvalidValue" -TargetObject $row
                        }
                        $record.Channel = $channelNumber
                    }
                    'UserName' {}
                    'Password' {}
                    'RecordingServer' {
                        if (-not [string]::IsNullOrWhiteSpace($record.RecordingServer) -and -not $recorders.ContainsKey($record.RecordingServer)) {
                            Write-Error -Message "Invalid RecordingServer value `"$($row.RecordingServer)`" in row $($i + 1)." -Category InvalidData -ErrorId "InvalidValue" -TargetObject $row
                        }
                    }
                    'DriverNumber' {
                        $driverNumber = 0
                        if ([string]::IsNullOrWhiteSpace($record.DriverNumber)) {
                            $record.DriverNumber = 0
                        }
                        if (-not [int]::TryParse($record.DriverNumber, [ref]$driverNumber)) {
                            Write-Error -Message "Invalid DriverNumber value `"$($row.DriverNumber)`" in row $($i + 1)." -Category InvalidData -ErrorId "InvalidValue" -TargetObject $row
                        }
                        # Only validate DriverNumber if RecordingServer exists - otherwise the recording server validation will have already thrown an error
                        if (-not [string]::IsNullOrWhiteSpace($record.RecordingServer) -and $recorders.ContainsKey($record.RecordingServer) -and -not [string]::IsNullOrWhiteSpace($row.DriverNumber) -and -not $driversByRecorder.ContainsKey("$($record.RecordingServer).$($record.DriverNumber)")) {
                            Write-Error -Message "DriverNumber `"$($row.DriverNumber)`" in row $($i + 1) not found on RecordingServer `"$($record.RecordingServer)`". You may need to install a newer device pack version or custom device driver." -Category InvalidData -ErrorId "InvalidValue" -TargetObject $row
                        }
                        $record.DriverNumber = $driverNumber
                    }
                    'DriverGroup' {}
                    'Enabled' {
                        $enabled = $true
                        if (-not [bool]::TryParse($record.Enabled, [ref]$enabled)) {
                            Write-Error -Message "Invalid Enabled value `"$($row.Enabled)`" in row $($i + 1)." -Category InvalidData -ErrorId "InvalidValue" -TargetObject $row
                        }
                        $record.Enabled = $enabled
                    }
                    'StorageName' {}
                    'HardwareName' {}
                    'Coordinates' {
                        if (-not [string]::IsNullOrWhiteSpace($record.Coordinates)) {
                            try {
                                $null = ConvertTo-GisPoint -Coordinates $record.Coordinates
                            } catch {
                                $errorParams = @{
                                    Message      = 'Invalid Coordinates value "{0}" in row {0}.' -f $row.Coordinates, ($i + 1)
                                    Category     = 'InvalidData'
                                    ErrorId      = 'InvalidValue'
                                    TargetObject = $row
                                }
                                if ($null -ne $_.Exception) {
                                    $errorParams.Exception = $_.Exception
                                }
                                Write-Error @errorParams
                            }
                        }
                    }
                    'DeviceGroups' {}
                    'Row' {}
                    'Path' {}
                    'Result' {}
                    Default {
                        Write-Verbose "Ignoring header `"$_`""
                    }
                }
            }
            
            $record
        }
    }
}
