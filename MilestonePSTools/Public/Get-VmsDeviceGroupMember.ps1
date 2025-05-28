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

function Get-VmsDeviceGroupMember {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipeline)]
        [ValidateVmsItemType('CameraGroup', 'MicrophoneGroup', 'MetadataGroup', 'SpeakerGroup', 'InputEventGroup', 'OutputGroup')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $Group,

        [Parameter()]
        [VideoOS.ConfigurationApi.ClientService.EnableFilter]
        $EnableFilter = [VideoOS.ConfigurationApi.ClientService.EnableFilter]::Enabled
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $deviceType = ($Group | Split-VmsConfigItemPath -ItemType) -replace 'Group$', ''
        $Group."$($deviceType)Folder"."$($deviceType)s" | ForEach-Object {
            if ($_.Enabled -and $EnableFilter -eq 'Disabled') {
                return
            }
            if (-not $_.Enabled -and $EnableFilter -eq 'Enabled') {
                return
            }
            $_
        }
    }
}

