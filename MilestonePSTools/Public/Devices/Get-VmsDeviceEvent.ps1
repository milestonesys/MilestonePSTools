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

function Get-VmsDeviceEvent {
    [CmdletBinding()]
    [MilestonePSTools.RequiresVmsConnection()]
    [MilestonePSTools.RequiresVmsVersion('21.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.HardwareDeviceEventChildItem])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateVmsItemType('Hardware', 'Camera', 'Microphone', 'Speaker', 'Metadata', 'InputEvent', 'Output')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $Device,

        [Parameter()]
        [SupportsWildcards()]
        [string]
        $Name = '*',

        [Parameter()]
        [bool]
        $Used,

        [Parameter()]
        [bool]
        $Enabled
    )

    begin {
        Assert-VmsRequirementsMet
    }
   
    process {
        $Device.HardwareDeviceEventFolder.ClearChildrenCache()
        $hardwareDeviceEvent = $Device.HardwareDeviceEventFolder.HardwareDeviceEvents | Select-Object -First 1
        $wildcardPattern = [system.management.automation.wildcardpattern]::new($Name, [System.Management.Automation.WildcardOptions]::IgnoreCase)
        foreach ($childItem in $hardwareDeviceEvent.HardwareDeviceEventChildItems | Sort-Object DisplayName) {
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Name')) {
                if (-not $wildcardPattern.IsMatch($childItem.DisplayName)) {
                    continue
                }
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Used') -and $childItem.EventUsed -ne $Used) {
                continue
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Enabled') -and $childItem.Enabled -ne $Enabled) {
                continue
            }
            
            # Used in Set-VmsDeviceEvent for more useful log messages and so that it's easy to know which event is associated with which device
            $childItem | Add-Member -MemberType NoteProperty -Name Device -Value $Device
            # Used in Set-VmsDeviceEvent because the .Save() method is on the parent HardwareDeviceEvent, not the HardwareDeviceEventChildItem.
            $childItem | Add-Member -MemberType NoteProperty -Name HardwareDeviceEvent -Value $hardwareDeviceEvent
            # Used in Set-VmsDeviceEvent to know whether to refresh our HardwareDeviceEvent before calling .Save().
            $hwPath = if ($Device.ParentItemPath -match '^Hardware') { $Device.ParentItemPath } else { $Device.Path }
            $childItem | Add-Member -MemberType NoteProperty -Name HardwarePath -Value $hwPath
            
            $childItem
        }
    }
}

