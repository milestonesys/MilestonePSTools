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

function Remove-VmsLoginProvider {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('22.1')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.LoginProvider]
        $LoginProvider,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($PSCmdlet.ShouldProcess("Login provider '$($LoginProvider.Name)'", 'Remove')) {
            if ($Force) {
                # Disable the login provider to ensure no external users login
                # and generate a new external basic user between the time the users
                # are removed and the provider is deleted.
                $LoginProvider | Set-VmsLoginProvider -Enabled $false -ErrorAction Stop -Verbose:($VerbosePreference -eq 'Continue')

                # The basic user folder may be cached already, and there may be
                # new external users on the VMS that are not present in the cache.
                # By clearing the cache we ensure that the next step removes all
                # external users.
                (Get-VmsManagementServer).BasicUserFolder.ClearChildrenCache()

                # Remove all basic users with claims associated with this login provider
                Get-VmsBasicUser -External | Where-Object {
                    $_.ClaimFolder.ClaimChildItems.ClaimProvider -contains $LoginProvider.Id
                } | Remove-VmsBasicUser -ErrorAction Stop -Verbose:($VerbosePreference -eq 'Continue')

                # Remove all claims associated with this login provider from all roles
                foreach ($role in Get-VmsRole) {
                    $claims = $role | Get-VmsRoleClaim | Where-Object ClaimProvider -EQ $LoginProvider.Id
                    if ($claims.Count -gt 0) {
                        $role | Remove-VmsRoleClaim -ClaimName $claims.ClaimName -ErrorAction Stop -Verbose:($VerbosePreference -eq 'Continue')
                    }
                }

                # Remove all claims registered on this login provider
                $LoginProvider | Remove-VmsLoginProviderClaim -All -ErrorAction Stop
            }
            $null = (Get-VmsManagementServer).LoginProviderFolder.RemoveLoginProvider($LoginProvider.Path)
        }
    }
}

