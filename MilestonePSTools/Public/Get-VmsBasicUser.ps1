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

function Get-VmsBasicUser {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.ConfigurationItems.BasicUser])]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter([MipItemNameCompleter[BasicUser]])]
        [string]
        $Name,

        [Parameter()]
        [ValidateSet('Enabled', 'LockedOutByAdmin', 'LockedOutBySystem')]
        [string]
        $Status,

        [Parameter()]
        [switch]
        $External
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $matchFound = $false
        foreach ($user in (Get-VmsManagementServer).BasicUserFolder.BasicUsers){
            if ($MyInvocation.BoundParameters.ContainsKey('Status') -and $user.Status -ne $Status) {
                continue
            }

            if ($MyInvocation.BoundParameters.ContainsKey('External') -and $user.IsExternal -ne $External) {
                continue
            }

            if ($MyInvocation.BoundParameters.ContainsKey('Name') -and $user.Name -ne $Name) {
                continue
            }
            $matchFound = $true
            $user
        }
        if ($MyInvocation.BoundParameters.ContainsKey('Name') -and -not $matchFound) {
            Write-Error "No basic user found matching the name '$Name'"
        }
    }
}


