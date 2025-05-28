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

function Remove-VmsHardware {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    [Alias('Remove-Hardware')]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.Hardware[]]
        $Hardware
    )

    begin {
        Assert-VmsRequirementsMet
        $recorders = @{}
        (Get-VmsManagementServer).RecordingServerFolder.RecordingServers | Foreach-Object {
            $recorders[$_.Path] = $_
        }
        $foldersNeedingCacheReset = @{}
    }

    process {
        try {
            $action = 'Permanently delete hardware and all associated video, audio and metadata from the VMS'
            foreach ($hw in $Hardware) {
                try {
                    $target = "$($hw.Name) with ID $($hw.Id)"
                    if ($PSCmdlet.ShouldProcess($target, $action)) {
                        $folder = $recorders[$hw.ParentItemPath].HardwareFolder
                        $result = $folder.DeleteHardware($hw.Path) | Wait-VmsTask -Title "Removing hardware $($hw.Name)" -Cleanup
                        $properties = @{}
                        $result.Properties | Foreach-Object { $properties[$_.Key] = $_.Value}
                        if ($properties.State -eq 'Success') {
                            $foldersNeedingCacheReset[$folder.Path] = $folder
                        } else {
                            Write-Error "An error occurred while deleting the hardware. $($properties.ErrorText.Trim('.'))."
                        }
                    }
                }
                catch [VideoOS.Platform.PathNotFoundMIPException] {
                    Write-Error "The hardware named $($hw.Name) with ID $($hw.Id) was not found."
                }
            }
        }
        catch [VideoOS.Platform.PathNotFoundMIPException] {
            Write-Error "One or more recording servers for the provided hardware values do not exist."
        }
    }

    end {
        $foldersNeedingCacheReset.Values | Foreach-Object {
            $_.ClearChildrenCache()
        }
    }
}

