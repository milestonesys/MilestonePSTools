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

function Remove-VmsDeviceGroup {
    [CmdletBinding(ConfirmImpact = 'High', SupportsShouldProcess)]
    [Alias('Remove-DeviceGroup')]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateVmsItemType('CameraGroup', 'MicrophoneGroup', 'MetadataGroup', 'SpeakerGroup', 'InputEventGroup', 'OutputGroup')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem[]]
        $Group,

        [Parameter()]
        [switch]
        $Recurse
    )

    begin {
        Assert-VmsRequirementsMet
        $cacheToClear = @{}
    }

    process {
        foreach ($g in $Group) {
            $itemType = $g | Split-VmsConfigItemPath -ItemType
            $target = "$itemType '$($g.Name)'"
            $action = "Delete"
            if ($Recurse) {
                $target += " and all group members"
            }
            if ($PSCmdlet.ShouldProcess($target, $action)) {
                try {
                    $parentFolder = Get-ConfigurationItem -Path $g.ParentPath
                    $invokeInfo = $parentFolder | Invoke-Method -MethodId RemoveDeviceGroup
                    if ($Recurse -and ($prop = $invokeInfo.Properties | Where-Object Key -eq 'RemoveMembers')) {
                        $prop.Value = $Recurse.ToString()
                    } elseif ($Recurse) {
                        # Versions around 2019 and older apparently didn't have a "RemoveMembers" option for recursively deleting device groups.
                        $members = $g | Get-VmsDeviceGroupMember -EnableFilter All
                        if ($members.Count -gt 0) {
                            $g | Remove-VmsDeviceGroupMember -Device $members -Confirm:$false
                        }
                        $g | Get-VmsDeviceGroup | Remove-VmsDeviceGroup -Recurse -Confirm:$false
                    }

                    ($invokeInfo.Properties | Where-Object Key -eq 'ItemSelection').Value = $g.Path
                    $null = $invokeInfo | Invoke-Method -MethodId RemoveDeviceGroup -ErrorAction Stop
                    $cacheToClear[$itemType] = $null
                } catch {
                    Write-Error -ErrorRecord $_
                }
            }
        }

    }

    end {
        $cacheToClear.Keys | Foreach-Object {
            Write-Verbose "Clearing $_ cache"
            (Get-VmsManagementServer)."$($_)Folder".ClearChildrenCache()
        }
    }
}

