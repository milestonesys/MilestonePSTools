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

function Set-VmsDeviceEvent {
    [CmdletBinding(SupportsShouldProcess)]
    [MilestonePSTools.RequiresVmsConnection()]
    [MilestonePSTools.RequiresVmsVersion('21.1')]
    [OutputType('None')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({
                if ($null -eq ($_ | Get-Member -MemberType NoteProperty -Name HardwareDeviceEvent)) {
                    throw 'DeviceEvent must be returned by Get-VmsDeviceEvent or it does not have a NoteProperty member named HardwareDeviceEvent.'
                }
                $true
            })]
        [VideoOS.Platform.ConfigurationItems.HardwareDeviceEventChildItem]
        $DeviceEvent,

        [Parameter()]
        [bool]
        $Used,

        [Parameter()]
        [bool]
        $Enabled,

        [Parameter()]
        [string]
        $Index,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
        $modified = @{}
    }
   
    process {
        $changes = @{}
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Used') -and $DeviceEvent.EventUsed -ne $Used) {
            $changes['EventUsed'] = $Used            
        }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Enabled') -and $DeviceEvent.Enabled -ne $Enabled) {
            $changes['Enabled'] = $Enabled         
        }
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Index') -and $DeviceEvent.EventIndex -ne $Index) {
            $changes['EventIndex'] = $Index
        }

        # Management Client sets EventUsed and Enabled to the same value when you add or remove them in the UI.
        if ($changes.ContainsKey('EventUsed') -and $changes['EventUsed'] -ne $DeviceEvent.Enabled) {
            $changes['Enabled'] = $changes['EventUsed']
        }

        if ($changes.Count -gt 0 -and $PSCmdlet.ShouldProcess($DeviceEvent.Device.Name, "Update '$($DeviceEvent.DisplayName)' device event settings")) {
            <#
             # BUG #627670 - This method does not work because you can only call Save() on the most recently queried HardwareDeviceEvent.
             # The LastModified datetime for the Hardware associated with the most recently queried HardwareDeviceEvent must match the
             # LastModified timestamp of the hardware associated with the HardwareDeviceEvent.Save() method.
             # This method will be ~30% faster if we can change the server-side behavior.
            
            foreach ($kvp in $changes.GetEnumerator()) {
                $DeviceEvent.($kvp.Key) = $kvp.Value
            }
            $modified[$DeviceEvent.Path] = $DeviceEvent
            
            #>
            
            
            # Alternate method to work around issue described in BUG #627670
            if (-not $modified.ContainsKey($DeviceEvent.Path)) {
                $modified[$DeviceEvent.Path] = [pscustomobject]@{
                    Device              = $DeviceEvent.Device
                    HardwareDeviceEvent = $DeviceEvent.HardwareDeviceEvent
                    Changes             = @{}
                }
            }
            $modified[$DeviceEvent.Path].Changes[$DeviceEvent.Id] = $changes
        } elseif ($PassThru) {
            $DeviceEvent
        }
    }

    end {
        <#
             # BUG #627670 - This method does not work because you can only call Save() on the most recently queried HardwareDeviceEvent.
             # The LastModified datetime for the Hardware associated with the most recently queried HardwareDeviceEvent must match the
             # LastModified timestamp of the hardware associated with the HardwareDeviceEvent.Save() method.
             # This method will be ~30% faster if we can change the server-side behavior.

             foreach ($item in $modified.Values) {
                try {
                    Write-Verbose "Saving device event changes on $($item.Device.Name)."
                    $item.HardwareDeviceEvent.Save()
                    if ($PassThru) {
                        $item
                    }
                } catch {
                    throw
                }
            }
        #>

        # Alternate method to work around issue described in BUG #627670
        foreach ($record in $modified.Values) {
            $record.Device.HardwareDeviceEventFolder.ClearChildrenCache()
            $hardwareDeviceEvent = [VideoOS.Platform.ConfigurationItems.HardwareDeviceEvent]::new($record.HardwareDeviceEvent.ServerId, $record.HardwareDeviceEvent.Path)
            $modifiedChildItems = $hardwareDeviceEvent.HardwareDeviceEventChildItems | Where-Object { $record.Changes.ContainsKey($_.Id) }
            foreach ($eventId in $record.Changes.Keys) {
                if (($childItem = $modifiedChildItems | Where-Object Id -eq $eventId)) {
                    foreach ($change in $record.Changes[$eventId].GetEnumerator()) {
                        Write-Verbose "Setting $($change.Key) = $($change.Value) for event '$($childItem.DisplayName)' on $($record.Device.Name)."
                        $childItem.($change.Key) = $change.Value
                    }
                } else {
                    throw "HardwareDeviceEventChildItem with ID $eventId not found on $($record.Device.Name)."
                }
            }
            Write-Verbose "Saving changes to HardwareDeviceEvents on $($record.Device.Name)"
            $hardwareDeviceEvent.Save()
            if ($PassThru) {
                $record.Device.HardwareDeviceEventFolder.ClearChildrenCache()
                $record.Device | Get-VmsDeviceEvent | Where-Object Id -in $modifiedChildItems.Id
            }
        }
    }
}

