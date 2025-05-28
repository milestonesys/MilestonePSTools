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

function Get-VmsAlarmDefinition {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.ConfigurationItems.AlarmDefinition])]
    [RequiresVmsConnection()]
    param (
        [Parameter()]
        [SupportsWildcards()]
        [System.Management.Automation.ArgumentCompleter([MilestonePSTools.Utility.MipItemNameCompleter[VideoOS.Platform.ConfigurationItems.AlarmDefinition]])]
        [string]
        $Name
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($PSBoundParameters.ContainsKey('Name')) {
            # Since the QueryItems feature doesn't support wildcards or regex, it isn't very good for searching as the
            # PowerShell user is used to using "Server*" and advanced users are used to using regex like '^Server'.
            # Because of this, this cmdlet is just going to use the -Like operator against all alarm definitions.
            (Get-VmsManagementServer).AlarmDefinitionFolder.AlarmDefinitions | Where-Object Name -like $Name
        } else {
            (Get-VmsManagementServer).AlarmDefinitionFolder.AlarmDefinitions
        }
    }
}
