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

function Set-VmsLoginProvider {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.LoginProvider])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('22.1')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter([MipItemNameCompleter[LoginProvider]])]
        [MipItemTransformation([LoginProvider])]
        [LoginProvider]
        $LoginProvider,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $ClientId,

        [Parameter()]
        [SecureStringTransformAttribute()]
        [securestring]
        $ClientSecret,

        [Parameter()]
        [ValidateVmsVersion('25.3')]
        [ValidateSet('SharedSecret', 'X509Thumbprint')]
        [string]
        $ClientSecretType,

        [Parameter()]
        [string]
        $CallbackPath,

        [Parameter()]
        [uri]
        $Authority,

        [Parameter()]
        [string]
        $UserNameClaim,

        [Parameter()]
        [string[]]
        $Scopes,

        [Parameter()]
        [bool]
        $PromptForLogin,

        [Parameter()]
        [bool]
        $Enabled,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        try {
            if ($PSCmdlet.ShouldProcess("Login provider '$($LoginProvider.Name)'", "Update")) {
                $dirty = $false
                $initialName = $LoginProvider.Name
                $keys = @()
                $MyInvocation.BoundParameters.GetEnumerator() | Where-Object Key -in $LoginProvider.GetPropertyKeys() | Foreach-Object {
                    $keys += $_.Key
                }
                if ($MyInvocation.BoundParameters.ContainsKey('Enabled')) {
                    $keys += 'Enabled'
                }
                if ($MyInvocation.BoundParameters.ContainsKey('UserNameClaim')) {
                    $keys += 'UserNameClaim'
                }
                foreach ($key in $keys) {
                    if ($key -eq 'Scopes') {
                        $differences = (($Scopes | Foreach-Object { $_ -in $LoginProvider.Scopes}) -eq $false).Count + (($LoginProvider.Scopes | Foreach-Object { $_ -in $Scopes}) -eq $false).Count
                        if ($differences -gt 0) {
                            Write-Verbose "Updating $key on login provider '$initialName'"
                            $LoginProvider.Scopes.Clear()
                            $Scopes | Foreach-Object {
                                $LoginProvider.Scopes.Add($_)
                            }
                            $dirty = $true
                        }
                    } elseif ($key -eq 'ClientSecret' -and $ClientSecretType -ne 'X509Thumbprint') {
                        Write-Verbose "Updating $key on login provider '$initialName'"
                        $cred = [pscredential]::new('a', $ClientSecret)
                        $LoginProvider.ClientSecret = $cred.GetNetworkCredential().Password
                        $dirty = $true
                    } elseif ($key -eq 'ClientSecret' -and $ClientSecretType -eq 'X509Thumbprint') {
                        # The secret carries a certificate thumbprint and is applied
                        # via the API Gateway below, not through the .NET SDK, so that
                        # clientSecretType can be set to X509Thumbprint.
                    } elseif ($key -eq 'Enabled' -and $LoginProvider.Enabled -ne $Enabled) {
                        Write-Verbose "Setting Enabled to $Enabled on login provider '$initialName'"
                        $LoginProvider.Enabled = $Enabled
                        $dirty = $true
                    } elseif ($key -eq 'UserNameClaim') {
                        Write-Verbose "Setting UserNameClaimType to $UserNameClaim on login provider '$initialName'"
                        $LoginProvider.UserNameClaimType = $UserNameClaim
                        $dirty = $true
                    } elseif ($LoginProvider.$key -cne (Get-Variable -Name $key).Value) {
                        Write-Verbose "Updating $key on login provider '$initialName'"
                        $LoginProvider.$key = (Get-Variable -Name $key).Value
                        $dirty = $true
                    }
                }
                if ($dirty) {
                    $LoginProvider.Save()
                } elseif ($ClientSecretType -ne 'X509Thumbprint') {
                    Write-Verbose "No changes were made to login provider '$initialName'."
                }

                if ($ClientSecretType -eq 'X509Thumbprint') {
                    if (-not $MyInvocation.BoundParameters.ContainsKey('ClientSecret')) {
                        throw "The ClientSecret parameter is required when ClientSecretType is 'X509Thumbprint'. Provide the certificate thumbprint as the ClientSecret value."
                    }
                    # The .NET SDK does not support the clientSecretType field, so
                    # certificate-based authentication is configured directly against
                    # the API Gateway REST endpoint.
                    Write-Verbose "Updating ClientSecret and ClientSecretType on login provider '$initialName' via the API Gateway"
                    $cred = [pscredential]::new('a', $ClientSecret)
                    $loginProviderBody = @{
                        clientSecret     = $cred.GetNetworkCredential().Password
                        clientSecretType = $ClientSecretType
                    }
                    $null = InvokeVmsRestApi -ResourcePath "loginproviders/$($LoginProvider.Id)" -Method 'PATCH' -Body $loginProviderBody
                    (Get-VmsManagementServer).LoginProviderFolder.ClearChildrenCache()
                    $LoginProvider = Get-VmsLoginProvider -Name $LoginProvider.Name
                }
            }

            if ($PassThru) {
                $LoginProvider
            }
        } catch {
            Write-Error -Message $_.Exception.Message -TargetObject $LoginProvider
        }
    }
}
