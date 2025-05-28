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

function Set-VmsDeviceGroup {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateVmsItemType('CameraGroup', 'MicrophoneGroup', 'MetadataGroup', 'SpeakerGroup', 'InputEventGroup', 'OutputGroup')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $Group,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $groupType = $Group | Split-VmsConfigItemPath -ItemType
        $dirty = $false
        $keys = $MyInvocation.BoundParameters.Keys | Where-Object { $_ -in @('Name', 'Description') }
        if ($PSCmdlet.ShouldProcess("$groupType '$($Group.Name)", "Update $([string]::Join(', ', $keys))")) {
            foreach ($key in $keys) {
                if ($Group.$key -cne $MyInvocation.BoundParameters[$key]) {
                    $Group.$key = $MyInvocation.BoundParameters[$key]
                    $dirty = $true
                }
            }
            if ($dirty) {
                Write-Verbose "Saving changes to $groupType '$($Group.Name)'"
                $Group.Save()
            } else {
                Write-Verbose "No changes made to $groupType '$($Group.Name)'"
            }
        }
        if ($PassThru) {
            $Group
        }
    }
}

