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

function Add-VmsDeviceGroupMember {
    [CmdletBinding()]
    [Alias('Add-DeviceGroupMember')]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateVmsItemType('CameraGroup', 'MicrophoneGroup', 'SpeakerGroup', 'MetadataGroup', 'InputEventGroup', 'OutputGroup')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $Group,

        [Parameter(Mandatory, Position = 0, ParameterSetName = 'ByObject')]
        [ValidateVmsItemType('Camera', 'Microphone', 'Speaker', 'Metadata', 'InputEvent', 'Output')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem[]]
        $Device,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1, ParameterSetName = 'ById')]
        [Alias('Id')]
        [guid[]]
        $DeviceId
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $dirty = $false
        $groupItemType = ($Group | Split-VmsConfigItemPath -ItemType) -replace 'Group$', ''
        try {
            if ($Device) {
                $DeviceId = $Device.Id
            }
            foreach ($id in $DeviceId) {
                try {
                    $path = '{0}[{1}]' -f $groupItemType, $id
                    $null = $Group."$($groupItemType)Folder".AddDeviceGroupMember($path)
                    $dirty = $true
                } catch [VideoOS.Platform.ArgumentMIPException] {
                    Write-Error -Message "Failed to add device group member: $_.Exception.Message" -Exception $_.Exception
                }
            }
        }
        finally {
            if ($dirty) {
                $Group."$($groupItemType)GroupFolder".ClearChildrenCache()
                (Get-VmsManagementServer)."$($groupItemType)GroupFolder".ClearChildrenCache()
            }
        }
    }
}

