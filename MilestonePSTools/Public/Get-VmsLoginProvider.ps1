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

function Get-VmsLoginProvider {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('22.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.LoginProvider])]
    param (
        [Parameter(Position = 0)]
        [ArgumentCompleter([MilestonePSTools.Utility.MipItemNameCompleter[VideoOS.Platform.ConfigurationItems.LoginProvider]])]
        [string]
        $Name
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {

        if ($MyInvocation.BoundParameters.ContainsKey('Name')) {
            $loginProviders = (Get-VmsManagementServer).LoginProviderFolder.LoginProviders | Where-Object Name -EQ $Name
        } else {
            $loginProviders = (Get-VmsManagementServer).LoginProviderFolder.LoginProviders | ForEach-Object { $_ }
        }
        if ($loginProviders) {
            $loginProviders
        } elseif ($MyInvocation.BoundParameters.ContainsKey('Name')) {
            Write-Error 'No matching login provider found.'
        }
    }
}

Register-ArgumentCompleter -CommandName Get-VmsLoginProvider -ParameterName Name -ScriptBlock {
    $values = (Get-VmsLoginProvider).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

