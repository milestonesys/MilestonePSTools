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

function Set-VmsClientProfileAttributes {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('SmartClientProfiles')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter([MipItemNameCompleter[ClientProfile]])]
        [MipItemTransformation([ClientProfile])]
        [ClientProfile]
        $ClientProfile,

        [Parameter(Position = 0)]
        [System.Collections.IDictionary]
        $Attributes,

        [Parameter()]
        [string]
        $Namespace
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $namespaces = ($ClientProfile | Get-Member -MemberType Property -Name 'ClientProfile*ChildItems').Name -replace 'ClientProfile(.+)ChildItems', '$1'
        if (-not $MyInvocation.BoundParameters.ContainsKey('Namespace')) {
            $Namespace = $Attributes.Namespace
        }
        if ([string]::IsNullOrWhiteSpace($Namespace)) {
            Write-Error "Client profile attribute namespace required. Either supply the namespace using the Namespace parameter, or include a Namespace key in the Attributes dictionary with the appropriate namespace name as a string value."
            return
        } elseif ($Namespace -notin $namespaces) {
            Write-Error "Client profile namespace '$Namespace' not found. Namespaces include $($namespaces -join ', ')."
            return
        }

        $settings = $ClientProfile."ClientProfile$($Namespace)ChildItems"
        $availableKeys = $settings.GetPropertyKeys()
        $dirty = $false
        foreach ($key in $Attributes.Keys | Where-Object { $_ -ne 'Namespace'}) {
            if ($key -notin $availableKeys) {
                Write-Warning "Client profile attribute with key '$key' not found in client profile namespace '$Namespace'."
                continue
            }

            if ($Attributes[$key].Value) {
                $newValue = $Attributes[$key].Value.ToString()
            } else {
                $newValue = $Attributes[$key].ToString()
            }

            if ($settings.GetProperty($key) -cne $newValue -and $PSCmdlet.ShouldProcess("$($ClientProfile.Name)/$Namespace/$key", "Change value from '$($settings.GetProperty($key))' to '$newValue'")) {
                $settings.SetProperty($key, $newValue)
                $dirty = $true
            }

            $locked = $null
            if ("$($key)Locked" -in $availableKeys) {
                $locked = $settings.GetProperty("$($key)Locked")
            }
            if ($null -ne $locked -and $null -ne $Attributes[$key].Locked -and $locked -ne $Attributes[$key].Locked.ToString() -and $PSCmdlet.ShouldProcess("$($ClientProfile.Name)/$Namespace/$($key)Locked", "Change value from '$locked' to '$($Attributes[$key].Locked.ToString())'")) {
                $settings.SetProperty("$($key)Locked", $Attributes[$key].Locked.ToString())
                $dirty = $true
            }
        }
        if ($dirty) {
            $ClientProfile.Save()
        }
    }
}

