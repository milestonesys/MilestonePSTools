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

function  Get-VmsVmoClient {
    <#
    .SYNOPSIS
    Gets a Milestone VMO Client used to access and configure a management server.
    
    .DESCRIPTION
    The VMO Client is used internally by Milestone's MIP SDK, but is not supported
    for external use unless otherwise specified. The raw VMO client is provided
    here to enable configuration of trusted issuers from PowerShell.
    
    .EXAMPLE
    $client = Get-VmsVmoClient
    
    Creates a VMO client and stores it in the $client variable.

    .NOTES
    Direct use of the VMO client is not necessary for configuring trusted issuers, but the
    client can be useful for troubleshooting, diagnostics, and experimentation.
    #>
    [CmdletBinding()]
    [OutputType([VideoOS.Management.VmoClient.VmoClient])]
    [MilestonePSTools.RequiresVmsConnection()]
    param ()

    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        $loginSettings = Get-LoginSettings
        $connection = [VideoOS.Management.VmoClient.ServerConnection]::new($loginSettings.UriCorporate.Host, $true, $loginSettings.IdentityTokenCache.TokenCache)
        [VideoOS.Management.VmoClient.VmoClient]::new($connection)
    }
}
