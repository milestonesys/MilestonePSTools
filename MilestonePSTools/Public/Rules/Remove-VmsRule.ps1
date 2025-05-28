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

function Remove-VmsRule {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.1')]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [RuleNameTransformAttribute()]
        [ValidateVmsItemType('Rule')]
        [VideoOS.ConfigurationApi.ClientService.ConfigurationItem]
        $Rule
    )

    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        if (-not $PSCmdlet.ShouldProcess($Rule.DisplayName, 'Remove')) {
            return
        }

        try {
            $invokeInfo = Get-ConfigurationItem -Path /RuleFolder | Invoke-Method RemoveRule
            $invokeInfo | Set-ConfigurationItemProperty -Key 'RemoveRulePath' -Value $Rule.Path
            $invokeInfo = $invokeInfo | Invoke-Method RemoveRule -ErrorAction Stop
            if (($invokeInfo | Get-ConfigurationItemProperty -Key State) -ne 'Success') {
                throw "Configuration API response did not indicate success."
            }
        } catch {
            Write-Error -Message $_.Exception.Message -Exception $_.Exception -TargetObject $invokeInfo
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-VmsRule -ParameterName Rule -ScriptBlock {
    $values = (Get-VmsRule).DisplayName | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

