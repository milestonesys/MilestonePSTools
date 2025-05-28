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

function Set-VmsDeviceStorage {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.IConfigurationItem])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem[]]
        $Device,

        [Parameter(Mandatory)]
        [string]
        $Destination,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet -ErrorAction Stop
    }
    
    process {
        foreach ($currentDevice in $Device) {
            try {
                $taskInfo = $currentDevice.ChangeDeviceRecordingStorage()
                $itemSelection =  $taskInfo.ItemSelectionValues.GetEnumerator() | Where-Object { $_.Value -eq $Destination -or $_.Key -eq $Destination }
                if ($itemSelection.Count -eq 0) {
                    Write-Error -TargetObject $currentDevice "No storage destination available for device '$currentDevice' named '$Destination'" -RecommendedAction "Use one of the available destinations: $($taskInfo.ItemSelectionValues.Keys -join ', ')"
                    continue
                } elseif ($itemSelection.Count -gt 1) {
                    Write-Error -TargetObject $currentDevice "More than one storage destination matching '$Destination' for device '$currentDevice'." -RecommendedAction "Check your recording server storage configuration. The only way you should see this error is if a storage configuration display name matches a storage configuration ID on that recording server."
                    continue
                }
                
                if ($PSCmdlet.ShouldProcess($currentDevice, "Set storage to $($itemSelection.Key)")) {
                    $taskInfo.ItemSelection = $itemSelection.Value
                    $task = $taskInfo.ExecuteDefault()
                    $null = $task | Wait-VmsTask -Title "Change device recording storage: $currentDevice" -Cleanup
                    if ($PassThru) {
                        $currentDevice
                    }
                }
            } catch {
                Write-Error -TargetObject $currentDevice -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category
            }
        }
    }
}

