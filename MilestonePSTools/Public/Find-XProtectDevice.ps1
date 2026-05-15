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

function Find-XProtectDevice {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.2')]
    param(
        # Specifies the ItemType such as Camera, Microphone, or InputEvent. Default is 'Camera'.
        [Parameter()]
        [ValidateSet('Hardware', 'Camera', 'Microphone', 'Speaker', 'InputEvent', 'Output', 'Metadata')]
        [string[]]
        $ItemType = 'Camera',

        # Specifies name, or part of the name of the device(s) to find.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        # Specifies all or part of the IP or hostname of the hardware device to search for.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Address,

        # Specifies all or part of the MAC address of the hardware device to search for. Note: Searching by MAC is significantly slower than searching by IP.
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $MacAddress,

        # Specifies whether all devices should be returned, or only enabled or disabled devices. Default is to return all matching devices.
        [Parameter()]
        [ValidateSet('All', 'Disabled', 'Enabled')]
        [string]
        $EnableFilter = 'All',

        # Specifies an optional hash table of key/value pairs matching properties on the items you're searching for.
        [Parameter()]
        [hashtable]
        $Properties = @{},

        [Parameter(ParameterSetName = 'ShowDialog')]
        [switch]
        $ShowDialog,

        [Parameter(ParameterSetName = 'ShowDialog')]
        [IntPtr]
        $OwnerHandle = [IntPtr]::Zero
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($ShowDialog) {
            Find-XProtectDeviceDialog -OwnerHandle $OwnerHandle
            return
        }
        if ($MyInvocation.BoundParameters.ContainsKey('Address')) {
            $ItemType = 'Hardware'
            $Properties.Address = $Address
        }

        if ($MyInvocation.BoundParameters.ContainsKey('MacAddress')) {
            $ItemType = 'Hardware'
            $MacAddress = $MacAddress.Replace(':', '').Replace('-', '')
        }
        # When many results are returned, this hashtable helps avoid unnecessary configuration api queries by caching parent items and indexing by their Path property
        $pathToItemMap = @{}

        Find-ConfigurationItem -ItemType $ItemType -EnableFilter $EnableFilter -Name $Name -Properties $Properties | Foreach-Object {
            $item = $_
            if (![string]::IsNullOrWhiteSpace($MacAddress)) {
                $hwid = ($item.Properties | Where-Object Key -eq 'Id').Value
                $mac = ((Get-ConfigurationItem -Path "HardwareDriverSettings[$hwid]").Children[0].Properties | Where-Object Key -like '*/MacAddress/*' | Select-Object -ExpandProperty Value).Replace(':', '').Replace('-', '')
                if ($mac -notlike "*$MacAddress*") {
                    return
                }
            }
            $deviceInfo = [ordered]@{}
            while ($true) {
                $deviceInfo.($item.ItemType) = $item.DisplayName
                if ($item.ItemType -eq 'RecordingServer') {
                    break
                }
                $parentItemPath = $item.ParentPath -split '/' | Select-Object -First 1

                # Set $item to the cached copy of that parent item if available. If not, retrieve it using configuration api and cache it.
                if ($pathToItemMap.ContainsKey($parentItemPath)) {
                    $item = $pathToItemMap.$parentItemPath
                } else {
                    $item = Get-ConfigurationItem -Path $parentItemPath
                    $pathToItemMap.$parentItemPath = $item
                }
            }
            [pscustomobject]$deviceInfo
        }
    }
}
