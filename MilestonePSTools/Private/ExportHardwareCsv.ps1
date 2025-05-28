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

function ExportHardwareCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [VideoOS.Platform.ConfigurationItems.Hardware[]]
        $Hardware,

        [Parameter()]
        [ValidateSet('Camera', 'Microphone', 'Speaker', 'Metadata', 'Input', 'Output')]
        [string[]]
        $DeviceType = @('Camera'),

        [Parameter()]
        [ValidateSet('All', 'Enabled', 'Disabled')]
        [string]
        $EnableFilter = 'Enabled'
    )

    process {
        $recorders = @{}
        $storage = @{}
        $deviceGroupsById = @{}
        $DeviceType | ForEach-Object {
            Get-VmsDeviceGroup -Type $_ -Recurse | ForEach-Object {
                $group = $_
                $groupPath = $group | Resolve-VmsDeviceGroupPath -NoTypePrefix
                foreach ($device in $group | Get-VmsDeviceGroupMember -EnableFilter $EnableFilter) {
                    if (-not $deviceGroupsById.ContainsKey($device.Id)) {
                        $deviceGroupsById[$device.Id] = [collections.generic.list[string]]::new()
                    }
                    $deviceGroupsById[$device.Id].Add($groupPath)
                }
            }
        }
        foreach ($hw in $Hardware) {
            if (-not $recorders.ContainsKey($hw.ParentItemPath)) {
                $recorders[$hw.ParentItemPath] = $hw | Get-VmsParentItem
            }
            $recorder = $recorders[$hw.ParentItemPath]
            
            try {
                $password = $hw | Get-VmsHardwarePassword
                $driver = $hw | Get-VmsHardwareDriver
            } catch {
                $password = $null
                $driver = $null
            }
            
            $splat = @{
                Type         = $DeviceType
                EnableFilter = $EnableFilter
            }
            foreach ($device in $hw | Get-VmsDevice @splat) {
                if ($null -ne $device.RecordingStorage -and -not $storage.ContainsKey($device.RecordingStorage)) {
                    $storage[$device.RecordingStorage] = $recorder | Get-VmsStorage | Where-Object Path -eq $device.RecordingStorage
                }
                $storageName = if ($device.RecordingStorage) { $storage[$device.RecordingStorage].Name } else { $null }
                $coordinates = if ($device.GisPoint -ne 'POINT EMPTY') { $device.GisPoint | ConvertFrom-GisPoint } else { $null }
                [pscustomobject]@{
                    DeviceType      = ($device.Path -split '\[' | Select-Object -First 1) -replace 'Event$'
                    Name            = $device.Name
                    Address         = $hw.Address
                    Channel         = $device.Channel
                    UserName        = $hw.UserName
                    Password        = $password
                    DriverNumber    = $driver.Number
                    DriverGroup    = $driver.GroupName
                    RecordingServer = $recorder.Name
                    Enabled         = $device.Enabled
                    HardwareName    = $hw.Name
                    StorageName     = $storageName
                    Coordinates     = $coordinates
                    DeviceGroups    = $deviceGroupsById[$device.Id] -join ';'
                }
            }
        }
    }
}
