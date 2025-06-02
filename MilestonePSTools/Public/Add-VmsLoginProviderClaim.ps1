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

function Add-VmsLoginProviderClaim {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('22.1')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter([MipItemNameCompleter[LoginProvider]])]
        [MipItemTransformation([LoginProvider])]
        [LoginProvider]
        $LoginProvider,

        [Parameter(Mandatory)]
        [string[]]
        $Name,

        [Parameter()]
        [string[]]
        $DisplayName,

        [Parameter()]
        [switch]
        $CaseSensitive
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($DisplayName.Count -gt 0 -and $DisplayName.Count -ne $Name.Count) {
            Write-Error "Number of claim names does not match the number of display names. When providing display names for claims, the number of DisplayName values must match the number of Name values."
            return
        }
        try {
            for ($index = 0; $index -lt $Name.Count; $index++) {
                $claimName = $Name[$index]
                $claimDisplayName = $Name[$index]
                if ($DisplayName.Count -gt 0) {
                    $claimDisplayName = $DisplayName[$index]
                }
                if ($PSCmdlet.ShouldProcess("Login provider '$($LoginProvider.Name)'", "Add claim '$claimName'")) {
                    $null = $LoginProvider.RegisteredClaimFolder.AddRegisteredClaim($claimName, $claimDisplayName, $CaseSensitive)
                }
            }
        } catch {
            Write-Error -Message $_.Exception.Message -TargetObject $LoginProvider
        }
    }
}
