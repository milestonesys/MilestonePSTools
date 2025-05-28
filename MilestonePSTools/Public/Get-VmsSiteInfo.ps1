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

function Get-VmsSiteInfo {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.2')]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateScript({ ValidateSiteInfoTagName @args })]
        [SupportsWildcards()]
        [string]
        $Property = '*'
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $ownerPath = 'BasicOwnerInformation[{0}]' -f (Get-VmsManagementServer).Id
        $ownerInfo = Get-ConfigurationItem -Path $ownerPath
        $resultFound = $false
        foreach ($p in $ownerInfo.Properties) {
            if ($p.Key -match '^\[(?<id>[a-fA-F0-9\-]{36})\]/(?<tagtype>[\w\.]+)$') {
                if ($Matches.tagtype -like $Property) {
                    $resultFound = $true
                    [pscustomobject]@{
                        DisplayName  = $p.DisplayName
                        Property   = $Matches.tagtype
                        Value = $p.Value
                    }
                }
            } else {
                Write-Warning "Site information property key format unrecognized: $($p.Key)"
            }
        }
        if (-not $resultFound -and -not [system.management.automation.wildcardpattern]::ContainsWildcardCharacters($Property)) {
            Write-Error "Site information property with key '$Property' not found."
        }
    }
}

Register-ArgumentCompleter -CommandName Get-VmsSiteInfo -ParameterName Property -ScriptBlock { OwnerInfoPropertyCompleter @args }

