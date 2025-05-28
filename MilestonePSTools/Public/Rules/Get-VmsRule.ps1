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

function Get-VmsRule {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.1')]
    param (
        [Parameter(ParameterSetName = 'Name', ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('DisplayName')]
        [SupportsWildcards()]
        [string]
        $Name = '*',

        [Parameter(Mandatory, ParameterSetName = 'Id')]
        [guid]
        $Id
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'Name' {
                    $matchFound = $false
                    Get-ConfigurationItem -Path /RuleFolder -ChildItems -ErrorAction Stop | Where-Object DisplayName -like $Name | Foreach-Object {
                        $matchFound = $true
                        $_
                    }
                    if (-not $matchFound -and -not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Name)) {
                        Write-Error "Rule with DisplayName '$($Name)' not found."
                    }
                }

                'Id' {
                    Get-ConfigurationItem -Path "Rule[$Id]" -ErrorAction Stop
                }
            }

        } catch {
            if ($null -eq (Get-ConfigurationItem -Path / -ChildItems | Where-Object Path -eq '/RuleFolder')) {
                Write-Error "The current VMS version does not support management of rules using configuration api."
            } elseif ($_.FullyQualifiedErrorId -match 'PathNotFoundExceptionFault') {
                Write-Error "Rule with Id '$Id' not found."
            } else {
                Write-Error -Message $_.Exception.Message -Exception $_.Exception
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Get-VmsRule -ParameterName Name -ScriptBlock {
    $values = (Get-VmsRule).DisplayName | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

