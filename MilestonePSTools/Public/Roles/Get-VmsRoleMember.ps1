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

function Get-VmsRoleMember {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.ConfigurationItems.User])]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipeline, Position = 0)]
        [Alias('RoleName')]
        [ArgumentCompleter([MipItemNameCompleter[Role]])]
        [MipItemTransformation([Role])]
        [Role[]]
        $Role
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($null -eq $Role) {
            $Role = Get-VmsRole
        }
        foreach ($record in $Role) {
            foreach ($user in $record.UserFolder.Users) {
                $user
            }
        }
    }
}
