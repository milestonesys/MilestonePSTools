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

function Get-VmsLoginProviderClaim {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.ConfigurationItems.RegisteredClaim])]
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
        $Name
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $LoginProvider.RegisteredClaimFolder.RegisteredClaims | Foreach-Object {
            if ($MyInvocation.BoundParameters.ContainsKey('Name') -and $_.Name -ne $Name) {
                return
            }
            $_
        }
    }
}
