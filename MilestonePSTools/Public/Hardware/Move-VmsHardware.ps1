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

function Move-VmsHardware {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([VideoOS.Platform.ConfigurationItems.Hardware])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter([MipItemNameCompleter[Hardware]])]
        [MipItemTransformation([Hardware])]
        [Hardware[]]
        $Hardware,

        [Parameter(Mandatory, Position = 1, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter([MipItemNameCompleter[RecordingServer]])]
        [MipItemTransformation([RecordingServer])]
        [RecordingServer]
        $DestinationRecorder,

        [Parameter(Mandatory, Position = 2, ValueFromPipelineByPropertyName)]
        [StorageNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.Storage]
        $DestinationStorage,

        [Parameter()]
        [switch]
        $AllowDataLoss,

        [Parameter()]
        [switch]
        $SkipDriverCheck,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
        $recordersByPath = @{}
        $moveSucceeded = $false
    }

    process {
        $recordersByPath[$DestinationRecorder.Path] = $DestinationRecorder
        foreach ($hw in $Hardware) {
            try {
                if ($null -eq $recordersByPath[$hw.ParentItemPath]) {
                    $recordersByPath[$hw.ParentItemPath] = Get-VmsRecordingServer | Where-Object Path -EQ $hw.ParentItemPath
                }
    
                if ($DestinationRecorder.Path -eq $hw.ParentItemPath) {
                    Write-Error "Hardware '$($hw.Name)' is already assigned to recorder '$($DestinationRecorder.Name)'." -TargetObject $hw
                    continue
                }
    
                if (-not $SkipDriverCheck) {
                    $srcDriver = $recordersByPath[$hw.ParentItemPath].HardwareDriverFolder.HardwareDrivers | Where-Object Path -EQ $hw.HardwareDriverPath
                    $dstDriver = $DestinationRecorder.HardwareDriverFolder.HardwareDrivers | Where-Object Path -EQ $hw.HardwareDriverPath
                    if ($null -eq $srcDriver) {
                        Write-Error "The current driver for hardware '$($hw.Name)' can not be determined."
                        continue
                    }
                    if ($null -eq $dstDriver) {
                        Write-Error "Destination recording server '$($DestinationRecorder.Name)' does not appear to have the following driver installed: $($srcDriver.Name) ($($srcDriver.Number))."
                        continue
                    }
                    if ("$($srcDriver.DriverVersion).$($srcDriver.DriverRevision)" -cne "$($dstDriver.DriverVersion).$($dstDriver.DriverRevision)") {
                        Write-Error "Destination recording server '$($DestinationRecorder.Name)' does not have the same driver version as source recording server '$($recordersByPath[$hw.ParentItemPath].Name)': Source = '$($srcDriver.DriverVersion), $($srcDriver.DriverRevision)', Destination = '$($dstDriver.DriverVersion), $($dstDriver.DriverRevision)'."
                        continue
                    }
                    Write-Verbose "Device pack driver versions and revisions match for driver '$($srcDriver.Name)': Source = '$($srcDriver.DriverVersion), $($srcDriver.DriverRevision)', Destination = '$($dstDriver.DriverVersion), $($dstDriver.DriverRevision)'."
                }
    
                if ($PSCmdlet.ShouldProcess($hw.Name, "Move hardware to $($DestinationRecorder.Name) / $($DestinationStorage.Name)")) {
                    $taskInfo = $hw.MoveHardware()
                    $taskInfo.SetProperty('DestinationRecordingServer', $DestinationRecorder.Path)
                    $taskInfo.SetProperty('DestinationStorage', $DestinationStorage.Path)
                    $taskInfo.SetProperty('ignoreSourceRecordingServer', $AllowDataLoss)
                    $result = $taskInfo.ExecuteDefault() | Wait-VmsTask -Cleanup
                    $errorText = ($result.Properties | Where-Object Key -EQ 'ErrorText').Value
                    if (-not [string]::IsNullOrWhiteSpace($errorText)) {
                        throw $errorText
                    }
                    $moveSucceeded = $true
    
                    foreach ($property in $result.Properties) {
                        if ($property.Key -match 'Warning' -and -not [string]::IsNullOrWhiteSpace($property.Value)) {
                            Write-Warning $property.Value
                        }
                    }
                }
                if ($PassThru) {
                    Get-VmsHardware -Id $hw.Id
                }
            } catch {
                throw
            }
        }
    }

    end {
        if ($moveSucceeded) {
            foreach ($recorder in $recordersByPath.Values) {
                Write-Verbose "Clearing HardwareFolder cache for $($recorder.Name)"
                $recorder.HardwareFolder.ClearChildrenCache()
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Move-VmsHardware -ParameterName DestinationStorage -ScriptBlock {
    $recorder = $null
    if ($null -eq ($recorder = $args[4]['DestinationRecorder'] -as [VideoOS.Platform.ConfigurationItems.RecordingServer])) {
        $recorder = Get-VmsRecordingServer | Where-Object Name -eq "$($args[4]['DestinationRecorder'])"
        if ($null -eq $recorder -or $recorder.Count -ne 1) {
            return
        }
    }
    $storages = $recorder | Get-VmsStorage | Select-Object -ExpandProperty Name -Unique | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $storages
}

