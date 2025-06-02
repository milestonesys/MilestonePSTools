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

function Remove-VmsRoleClaim {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('22.1')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('RoleName')]
        [ValidateNotNull()]
        [ArgumentCompleter([MipItemNameCompleter[Role]])]
        [MipItemTransformation([Role])]
        [Role[]]
        $Role,

        [Parameter(ValueFromPipelineByPropertyName, Position = 1)]
        [Alias('ClaimProvider')]
        [ArgumentCompleter([MipItemNameCompleter[LoginProvider]])]
        [MipItemTransformation([LoginProvider])]
        [LoginProvider]
        $LoginProvider,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 2)]
        [string[]]
        $ClaimName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $ClaimValue
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        foreach ($r in $Role) {
            $claims = $r | Get-VmsRoleClaim | Where-Object ClaimName -in $ClaimName
            if ($claims.Count -eq 0) {
                Write-Error "No matching claims found on role $($r.Name)."
                continue
            }
            foreach ($c in $claims) {
                if (-not [string]::IsNullOrWhiteSpace($ClaimValue) -and $c.ClaimValue -ne $ClaimValue) {
                    continue
                }
                if ($null -ne $LoginProvider -and $c.ClaimProvider -ne $LoginProvider.Id) {
                    continue
                }
                try {
                    if ($PSCmdlet.ShouldProcess("Claim '$($c.ClaimName)' on role '$($r.Name)'", "Remove")) {
                        $null = $r.ClaimFolder.RemoveRoleClaim($c.ClaimProvider, $c.ClaimName, $c.ClaimValue)
                    }
                } catch {
                    Write-Error -Message $_.Exception.Message -TargetObject $c
                }
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-VmsRoleClaim -ParameterName ClaimName -ScriptBlock {
    $values = (Get-VmsLoginProvider | Get-VmsLoginProviderClaim).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}
