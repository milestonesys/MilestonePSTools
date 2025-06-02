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

function Remove-VmsLoginProviderClaim {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('22.1')]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'All')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Name')]
        [ArgumentCompleter([MipItemNameCompleter[LoginProvider]])]
        [MipItemTransformation([LoginProvider])]
        [LoginProvider]
        $LoginProvider,

        [Parameter(Mandatory, ParameterSetName = 'All')]
        [switch]
        $All,

        [Parameter(Mandatory, ParameterSetName = 'Name')]
        [string]
        $ClaimName,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($Force) {
            Get-VmsRole | Foreach-Object {
                $currentRole = $_
                $claims = $currentRole | Get-VmsRoleClaim -LoginProvider $LoginProvider | Where-Object {
                    $All -or $_.ClaimName -eq $ClaimName
                }
                if ($claims.Count -eq 0) {
                    return
                }
                $currentRole | Remove-VmsRoleClaim -ClaimName $claims.ClaimName
            }
        }
        $folder = $LoginProvider.RegisteredClaimFolder
        $LoginProvider | Get-VmsLoginProviderClaim | Foreach-Object {
            if (-not [string]::IsNullOrWhiteSpace($ClaimName) -and $_.Name -notlike $ClaimName) {
                return
            }
            if ($PSCmdlet.ShouldProcess("Registered claim '$($_.DisplayName)'", "Remove")) {
                $null = $folder.RemoveRegisteredClaim($_.Path)
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-VmsLoginProviderClaim -ParameterName ClaimName -ScriptBlock {
    $values = (Get-VmsLoginProvider | Get-VmsLoginProviderClaim).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}
