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

function Set-VmsRule {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.1')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [RuleNameTransformAttribute()]
        [ValidateVmsItemType('Rule')]
        [VideoOS.ConfigurationApi.ClientService.ConfigurationItem]
        $Rule,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [BooleanTransformAttribute()]
        [bool]
        $Enabled,

        [Parameter()]
        [PropertyCollectionTransformAttribute()]
        [hashtable]
        $Properties,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $dirty = $false
        if ($MyInvocation.BoundParameters.ContainsKey('Name')) {
            $currentValue = $Rule | Get-ConfigurationItemProperty -Key Name
            if ($Name -cne $currentValue -and $PSCmdlet.ShouldProcess("Rule '$($Rule.DisplayName)'", "Set DisplayName to $Name")) {
                $Rule.DisplayName = $Name
                $Rule | Set-ConfigurationItemProperty -Key Name -Value $Name
                $dirty = $true
            }
        }
        if ($MyInvocation.BoundParameters.ContainsKey('Enabled')) {
            if ($Enabled -ne $Rule.EnableProperty.Enabled -and $PSCmdlet.ShouldProcess("Rule '$($Rule.DisplayName)'", "Set Enabled to $Enabled")) {
                $Rule.EnableProperty.Enabled = $Enabled
                $dirty = $true
            }
        }

        if ($MyInvocation.BoundParameters.ContainsKey('Properties') -and $PSCmdlet.ShouldProcess("Rule '$($Rule.DisplayName)'", "Update properties")) {
            $currentProperties = @{}
            $Rule.Properties | ForEach-Object {
                $currentProperties[$_.Key] = $_.Value
            }
            foreach ($newProperty in $Properties.GetEnumerator()) {
                if ($currentProperties.ContainsKey($newProperty.Key)) {
                    if ($newProperty.Value -cne $currentProperties[$newProperty.Key]) {
                        $Rule | Set-ConfigurationItemProperty -Key $newProperty.Key -Value $newProperty.Value
                        $dirty = $true
                    }
                } else {
                    $Rule.Properties += [VideoOS.ConfigurationApi.ClientService.Property]@{ Key = $newProperty.Key; Value = $newProperty.Value.ToString() }
                    $dirty = $true
                }
            }
        }

        if ($dirty -and $PSCmdlet.ShouldProcess("Rule '$($Rule.DisplayName)'", 'Save changes')) {
            $null = $Rule | Set-ConfigurationItem
        }

        if ($PassThru) {
            $Rule
        }
    }
}

Register-ArgumentCompleter -CommandName Set-VmsRule -ParameterName Rule -ScriptBlock {
    $values = (Get-VmsRule).DisplayName | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

