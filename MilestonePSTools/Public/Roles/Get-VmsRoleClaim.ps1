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

function Get-VmsRoleClaim {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.ConfigurationItems.ClaimChildItem])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('22.1')]
    param (
        [Parameter(ValueFromPipeline, Position = 0)]
        [Alias('RoleName')]
        [ArgumentCompleter([MipItemNameCompleter[Role]])]
        [MipItemTransformation([Role])]
        [Role[]]
        $Role,

        [Parameter(Position = 1)]
        [string[]]
        $ClaimName,

        [Parameter()]
        [ArgumentCompleter([MipItemNameCompleter[LoginProvider]])]
        [MipItemTransformation([LoginProvider])]
        [LoginProvider]
        $LoginProvider
    )

    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        if ($null -eq $Role) {
            $Role = Get-VmsRole
        }
        foreach ($r in $Role) {
            $matchFound = $false
            foreach ($claim in $r.ClaimFolder.ClaimChildItems) {
                if ($MyInvocation.BoundParameters.ContainsKey('ClaimName') -and $claim.ClaimName -notin $ClaimName) {
                    continue
                }
                if ($MyInvocation.BoundParameters.ContainsKey('LoginProvider') -and $claim.ClaimProvider -ne $LoginProvider.Id) {
                    continue
                }
                $claim
                $matchFound = $true
            }
            if ($MyInvocation.BoundParameters.ContainsKey('ClaimName') -and -not $matchFound) {
                Write-Error "No claim found matching the name '$ClaimName' in role '$($r.Name)'."
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Get-VmsRoleClaim -ParameterName ClaimName -ScriptBlock {
    $values = (Get-VmsLoginProvider | Get-VmsLoginProviderClaim).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}
