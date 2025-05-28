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

function Remove-VmsTrustedIssuer {
    <#
    .SYNOPSIS
    Removes an existing TrustedIssuer record.
    
    .DESCRIPTION
    The Remove-VmsTrustedIssuer command is used to remove or delete an existing TrustedIssuer.
    
    .PARAMETER TrustedIssuer
    Specifies a TrustedIssuer record returned by the Get-VmsTrustedIssuer command.
    
    .EXAMPLE
    Get-VmsTrustedIssuer -Id 4 | Remove-VmsTrustedIssuer
    
    Deletes the TrustedIssuer with Id "4".

    .EXAMPLE
    Get-VmsTrustedIssuer | Remove-VmsTrustedIssuer

    Deletes all TrustedIssuer records.
    #>
    [CmdletBinding()]
    [MilestonePSTools.RequiresVmsConnection()]
    [MilestonePSTools.RequiresVmsFeature('FederatedSites')]
    [MilestonePSTools.RequiresVmsWindowsUser()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Management.VmoClient.TrustedIssuer]
        $TrustedIssuer
    )
    
    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $TrustedIssuer.Delete()
    }
}
