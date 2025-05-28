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

function Get-VmsClientProfile {
    [CmdletBinding(DefaultParameterSetName = 'Name')]
    [OutputType([VideoOS.Platform.ConfigurationItems.ClientProfile])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('SmartClientProfiles')]
    param (
        [Parameter(ParameterSetName = 'Name', ValueFromPipelineByPropertyName, Position = 0)]
        [ArgumentCompleter([MilestonePSTools.Utility.MipItemNameCompleter[VideoOS.Platform.ConfigurationItems.ClientProfile]])]
        [SupportsWildcards()]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'Id', ValueFromPipelineByPropertyName)]
        [guid]
        $Id,

        [Parameter(Mandatory, ParameterSetName = 'DefaultProfile')]
        [switch]
        $DefaultProfile
    )

    begin {
        Assert-VmsRequirementsMet
        $folder = (Get-VmsManagementServer -ErrorAction Stop).ClientProfileFolder
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Id' {
                [VideoOS.Platform.ConfigurationItems.ClientProfile]::new($folder.ServerId, "ClientProfile[$Id]")
            }

            'Name' {
                $matchingProfiles = $folder.ClientProfiles | Where-Object {
                    [string]::IsNullOrWhiteSpace($Name) -or $_.Name -like $Name
                }
                if ($matchingProfiles) {
                    $matchingProfiles
                } elseif (-not [system.management.automation.wildcardpattern]::ContainsWildcardCharacters($Name)) {
                    Write-Error -Message "ClientProfile '$Name' not found."
                }
            }

            'DefaultProfile' {
                Get-VmsClientProfile | Where-Object IsDefaultProfile -eq $DefaultProfile
            }

            default {
                throw "ParameterSetName '$_' not implemented."
            }
        }
    }
}

