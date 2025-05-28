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

function Get-VmsRole {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    [RequiresVmsConnection()]
    [OutputType([VideoOS.Platform.ConfigurationItems.Role])]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName, ParameterSetName = 'ByName')]
        [ArgumentCompleter([MilestonePSTools.Utility.MipItemNameCompleter[VideoOS.Platform.ConfigurationItems.Role]])]
        [string]
        $Name = '*',

        [Parameter(ParameterSetName = 'ByName')]
        [string]
        $RoleType = '*',

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ById')]
        [Alias('RoleId')]
        [guid]
        $Id
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            try {
                [VideoOS.Platform.ConfigurationItems.Role]::new((Get-VmsManagementServer).ServerId, "Role[$Id]")
            } catch [VideoOS.Platform.PathNotFoundMIPException] {
                Write-Error -Message "No item found with ID matching $Id" -Exception $_.Exception
            }
        } else {
            $matchFound = $false
            foreach ($role in (Get-VmsManagementServer).RoleFolder.Roles) {
                if ($role.Name -notlike $Name -or $role.RoleType -notlike $RoleType) {
                    continue
                }
                if ($null -eq $role.ClientProfile) {
                    # TODO: Added because the ClientProfile, RoleDefaultTimeProfile, and RoleClientLogOnTimeProfile are $null
                    # when enumerating a role from the RoleFolder.Roles collection. If it's not null, then the MIP SDK
                    # behavior will have improved and we can avoid extra API calls by returning cached values.
                    [VideoOS.Platform.ConfigurationItems.Role]::new($role.ServerId, $role.Path)
                } else {
                    $role
                }
                $matchFound = $true
            }
            if (-not $matchFound -and -not [management.automation.wildcardpattern]::ContainsWildcardCharacters($Name)) {
                Write-Error "Role '$Name' not found."
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Get-VmsRole -ParameterName Id -ScriptBlock {
    $values = (Get-VmsManagementServer).RoleFolder.Roles.Id
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

Register-ArgumentCompleter -CommandName Get-VmsRole -ParameterName RoleType -ScriptBlock {
    $values = (Get-VmsManagementServer).RoleFolder.Roles[0].RoleTypeValues.Values | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

