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

function Resolve-VmsDeviceGroupPath {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('DeviceGroup')]
        [ValidateVmsItemType('CameraGroup', 'MicrophoneGroup', 'SpeakerGroup', 'MetadataGroup', 'InputEventGroup', 'OutputGroup')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $Group,

        [Parameter()]
        [switch]
        $NoTypePrefix
    )

    begin {
        Assert-VmsRequirementsMet
        $ctor = $null
        $sb = [text.stringbuilder]::new()
    }

    process {
        if ($null -eq $ctor -or $ctor.ReflectedType -ne $Group.GetType()) {
            $ctor = $Group.GetType().GetConstructor(@([videoos.platform.serverid], [string]))
        }
        try {
            $current = $Group
            $null = $sb.Clear().Insert(0, "/$($current.Name -replace '(?<!`)/', '`/')")
            while ($current.ParentItemPath -ne '/') {
                $current = $ctor.Invoke(@($current.ServerId, $current.ParentItemPath))
                $null = $sb.Insert(0, "/$($current.Name -replace '(?<!`)/', '`/')")
            }
            if (-not $NoTypePrefix) {
                $null = $sb.Insert(0, $current.ParentPath)
            }
            $sb.ToString()
        } catch {
            throw
        }
    }
}
