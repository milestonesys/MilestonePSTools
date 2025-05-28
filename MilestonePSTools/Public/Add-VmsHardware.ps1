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

function Add-VmsHardware {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.ConfigurationItems.Hardware])]
    [RequiresVmsConnection()]
    param (
        [Parameter(ParameterSetName = 'FromHardwareScan', Mandatory, ValueFromPipeline)]
        [VmsHardwareScanResult[]]
        $HardwareScan,

        [Parameter(ParameterSetName = 'Manual', Mandatory, ValueFromPipeline)]
        [RecorderNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.RecordingServer]
        $RecordingServer,

        [Parameter(ParameterSetName = 'Manual', Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Address')]
        [uri]
        $HardwareAddress,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(ParameterSetName = 'Manual')]
        [int]
        $DriverNumber,

        [Parameter(ParameterSetName = 'Manual', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $HardwareDriverPath,

        [Parameter(ParameterSetName = 'Manual', Mandatory)]
        [pscredential]
        $Credential,

        [Parameter()]
        [switch]
        $SkipConfig,

        # Specifies that the hardware should be added, even if it already exists on another recording server.
        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $recorders = @{}
        $tasks = New-Object System.Collections.Generic.List[VideoOS.Platform.ConfigurationItems.ServerTask]
        switch ($PSCmdlet.ParameterSetName) {
            'Manual' {
                if ([string]::IsNullOrWhiteSpace($HardwareDriverPath)) {
                    if ($MyInvocation.BoundParameters.ContainsKey('DriverNumber')) {
                        $hardwareDriver = $RecordingServer.HardwareDriverFolder.HardwareDrivers | Where-Object Number -eq $DriverNumber
                        if ($null -ne $hardwareDriver) {
                            Write-Verbose "Mapped DriverNumber $DriverNumber to $($hardwareDriver.Name)"
                            $HardwareDriverPath = $hardwareDriver.Path
                        } else {
                            Write-Error "Failed to find hardware driver matching driver number $DriverNumber on Recording Server '$($RecordingServer.Name)'"
                            return
                        }
                    } else {
                        Write-Error "Add-VmsHardware cannot continue without either the HardwareDriverPath or the user-friendly driver number found in the supported hardware list."
                        return
                    }
                }
                $serverTask = $RecordingServer.AddHardware($HardwareAddress, $HardwareDriverPath, $Credential.UserName, $Credential.Password)
                $tasks.Add($serverTask)
                $recorders[$RecordingServer.Path] = $RecordingServer
            }
            'FromHardwareScan' {
                if ($HardwareScan.HardwareScanValidated -contains $false) {
                    Write-Warning "One or more scanned hardware could not be validated. These entries will be skipped."
                }
                if ($HardwareScan.MacAddressExistsLocal -contains $true) {
                    Write-Warning "One or more scanned hardware already exist on the target recording server. These entries will be skipped."
                }
                if ($HardwareScan.MacAddressExistsGlobal -contains $true -and -not $Force) {
                    Write-Warning "One or more scanned hardware already exist on another recording server. These entries will be skipped since the Force switch was not used."
                }
                foreach ($scan in $HardwareScan | Where-Object { $_.HardwareScanValidated -and -not $_.MacAddressExistsLocal }) {
                    if ($scan.MacAddressExistsGlobal -and -not $Force) {
                        continue
                    }
                    Write-Verbose "Adding $($scan.HardwareAddress) to $($scan.RecordingServer.Name) using driver identified by $($scan.HardwareDriverPath)"
                    $serverTask = $scan.RecordingServer.AddHardware($scan.HardwareAddress, $scan.HardwareDriverPath, $scan.UserName, $scan.Password)
                    $tasks.Add($serverTask)
                }
            }
        }
        if ($tasks.Count -eq 0) {
            return
        }
        Write-Verbose "Awaiting $($tasks.Count) AddHardware requests"
        Write-Verbose "Tasks: $([string]::Join(', ', $tasks.Path))"
        Wait-VmsTask -Path $tasks.Path -Title "Adding hardware to recording server(s) on site $((Get-VmsSite).Name)" -Cleanup | Foreach-Object {
            $vmsTask = [VmsTaskResult]$_
            if ($vmsTask.State -eq [VmsTaskState]::Success) {
                $hardwareId = $vmsTask | Split-VmsConfigItemPath -Id
                $newHardware = Get-VmsHardware -Id $hardwareId
                if ($null -eq $recorders[$newHardware.ParentItemPath]) {
                    Get-VmsRecordingServer | Where-Object Path -eq $newHardware.ParentItemPath | Foreach-Object {
                        $recorders[$_.Path] = $_
                    }
                }

                if (-not $SkipConfig) {
                    Set-NewHardwareConfig -Hardware $newHardware -Name $Name
                }
                if ($null -ne $newHardware) {
                    $newHardware
                }
            } else {
                Write-Error "Add-VmsHardware failed with error code $($vmsTask.ErrorCode). $($vmsTask.ErrorText)"
            }
        }

        $recorders.Values | Foreach-Object {
            $_.HardwareFolder.ClearChildrenCache()
        }
    }
}

function Set-NewHardwareConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [VideoOS.Platform.ConfigurationItems.Hardware]
        $Hardware,

        [Parameter()]
        [string]
        $Name
    )

    process {
        $systemInfo = [videoos.platform.configuration]::Instance.FindSystemInfo((Get-VmsSite).FQID.ServerId, $true)
        $version = $systemInfo.Properties.ProductVersion -as [version]
        $itemTypes = @('Camera')
        if (-not [string]::IsNullOrWhiteSpace($Name)) {
            $itemTypes += 'Microphone', 'Speaker', 'Metadata', 'InputEvent', 'Output'
        }
        if ($version -ge '20.2') {
            $Hardware.FillChildren($itemTypes)
        }

        $Hardware.Enabled = $true
        if (-not [string]::IsNullOrWhiteSpace($Name)) {
            $Hardware.Name = $Name
        }
        $Hardware.Save()

        foreach ($itemType in $itemTypes) {
            foreach ($item in $Hardware."$($itemType)Folder"."$($itemType)s") {
                if (-not [string]::IsNullOrWhiteSpace($Name)) {
                    $newName = '{0} - {1} {2}' -f $Name, $itemType.Replace('Event', ''), ($item.Channel + 1)
                    $item.Name = $newName
                }
                if ($itemType -eq 'Camera' -and $item.Channel -eq 0) {
                    $item.Enabled = $true
                }
                $item.Save()
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Add-VmsHardware -ParameterName RecordingServer -ScriptBlock {
    $values = (Get-VmsRecordingServer).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

