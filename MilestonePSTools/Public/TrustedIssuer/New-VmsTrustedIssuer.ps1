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

function New-VmsTrustedIssuer {
    <#
    .SYNOPSIS
    Creates a new Trusted Issuer on the current Milestone XProtect VMS.
    
    .DESCRIPTION
    This command is used on a child site in a Milestone XProtect VMS to add a parent site as a trusted issuer of tokens.
    This is currently necessary to allow external OIDC identities from Azure or other identity providers to access all
    sites in a Milestone Federated Hierarchy.
    
    .PARAMETER Address
    Specifies the base address of the trusted Milestone Identity Provider (IDP). Normally this will be a URI like
    "https://parentsite.domain/IDP".
    
    .PARAMETER Issuer
    Specifies the OpenID Connect "issuer" string found in the "/IDP/.well-known/openid-configuration" JSON document of
    the new trusted issuer. If this is not provided, it will be discovered automatically. Under normal circumstances the
    value of "issuer" is the same as "Address".
    
    .PARAMETER Force
    Skips validation of the Issuer if provided.
    
    .EXAMPLE
    New-VmsTrustedIssuer -Address https://parentsite.domain/IDP

    Creates a new TrustedIssuer record for the management server at "https://parentsite.domain".
    
    .NOTES
    You must be logged in to the child site using a Windows account. Trusted Issuer records currently cannot be managed
    using a basic user account or an external identity.
    #>
    [CmdletBinding()]
    [OutputType([VideoOS.Management.VmoClient.TrustedIssuer])]
    [MilestonePSTools.RequiresVmsConnection()]
    [MilestonePSTools.RequiresVmsWindowsUser()]
    [MilestonePSTools.RequiresVmsFeature('FederatedSites')]
    param (
        [Parameter()]
        [uri]
        $Address
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if (!$PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Address')) {
            if (![uri]::TryCreate((Get-VmsManagementServer).MasterSiteAddress, [urikind]::Absolute, [ref]$Address)) {
                Write-Error "No address was provided and no valid MasterSiteAddress value is available on this management server. Ensure this management server is added as a child site in a Milestone Federated Architecture hierarchy."
                return
            }
        }

        $issuerUri = (Get-VmsOpenIdConfig -Address $Address -ErrorAction Stop).issuer
        $client = Get-VmsVmoClient
        try {
            $trustedIssuer = [VideoOS.Management.VmoClient.TrustedIssuer]::new($client.ManagementServer, $issuerUri, $issuerUri)
            $trustedIssuer.Create()
            $trustedIssuer
        } catch {
            Write-Error -Message "Failed to create a TrustedIssuer record for $issuerUri. See the exception for more information." -Exception $_.Exception
        }
    }
}
