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

function Get-VmsClientProfileAttributes {
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('SmartClientProfiles')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Command has already been published.')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter([MipItemNameCompleter[ClientProfile]])]
        [MipItemTransformation([ClientProfile])]
        [ClientProfile]
        $ClientProfile,

        [Parameter(Position = 0)]
        [string[]]
        $Namespace,

        [Parameter()]
        [switch]
        $ValueTypeInfo
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $namespaces = ($ClientProfile | Get-Member -MemberType Property -Name 'ClientProfile*ChildItems').Name -replace 'ClientProfile(.+)ChildItems', '$1'
        if ($Namespace.Count -eq 0) {
            $Namespace = $namespaces
        }

        foreach ($ns in $Namespace) {
            if ($ns -notin $namespaces) {
                Write-Error "Property 'ClientProfile$($ns)ChildItems' does not exist on client profile '$($ClientProfile.DisplayName)'"
                continue
            }
            $settings = $ClientProfile."ClientProfile$($ns)ChildItems"
            $attributes = [ordered]@{
                Namespace = $ns
            }
            if ($settings.Count -eq 0) {
                Write-Verbose "Ignoring empty client profile namespace '$ns'."
                continue
            }
            foreach ($key in $settings.GetPropertyKeys() | Where-Object { $_ -notmatch '(?<!Locked)Locked$' } | Sort-Object) {
                $attributes[$key] = [pscustomobject]@{
                    Value         = $settings.GetProperty($key)
                    ValueTypeInfo = if ($ValueTypeInfo) { $settings.GetValueTypeInfoList($key) } else { $null }
                    Locked        = $settings."$($key)Locked"
                }
            }
            $attributes
        }
    }
}

Register-ArgumentCompleter -CommandName Get-VmsClientProfileAttributes -ParameterName Namespace -ScriptBlock {
    $values = (Get-VmsClientProfile -DefaultProfile | Get-VmsClientProfileAttributes).Namespace | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

