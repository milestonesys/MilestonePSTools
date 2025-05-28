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

function Get-VmsTrustedIssuer {
    <#
    .SYNOPSIS
    Gets the specified, or all TrustedIssuer records from the current Milestone XProtect VMS.
    
    .DESCRIPTION
    Gets the specified, or all TrustedIssuer records from the current Milestone XProtect VMS.
    
    .PARAMETER Id
    Specifies the integer ID value for the TrustedIssuer record to retrieve.
    
    .PARAMETER Refresh
    Specifies that any previously cached copies of the TrustedIssuer(s) should be refreshed.
    
    .EXAMPLE
    Get-VmsTrustedIssuer | Select-Object Id, Issuer, Address
    
    Gets a list of existing TrustedIssuer records and returns the Id, Issuer, and Address properties.
    #>
    [CmdletBinding()]
    [OutputType([VideoOS.Management.VmoClient.TrustedIssuer])]
    [MilestonePSTools.RequiresVmsConnection()]
    [MilestonePSTools.RequiresVmsWindowsUser()]
    [MilestonePSTools.RequiresVmsFeature('FederatedSites')]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]
        $Id,

        [Parameter()]
        [switch]
        $Refresh
    )
    
    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            $client = Get-VmsVmoClient
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Id')) {
                $method = $client.Repositories.GetType().GetMethod('GetObjectById', [type[]]@([int], [boolean])).MakeGenericMethod([VideoOS.Management.VmoClient.TrustedIssuer])
                $method.Invoke($client.Repositories, @($Id, $Refresh.ToBool()))
            } else {
                $method = $client.Repositories.GetType().GetMethod('GetObjectsByParentId', [type[]]@([guid], [boolean])).MakeGenericMethod([VideoOS.Management.VmoClient.ManagementServer], [VideoOS.Management.VmoClient.TrustedIssuer])
                $method.Invoke($client.Repositories, @($client.ManagementServer.Id, $Refresh.ToBool()))
            }
        } catch {
            throw
        }
    }
}
