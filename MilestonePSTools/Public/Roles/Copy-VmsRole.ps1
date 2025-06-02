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

function Copy-VmsRole {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.ConfigurationItems.Role])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter([MipItemNameCompleter[Role]])]
        [MipItemTransformation([Role])]
        [Role]
        $Role,

        [Parameter(Mandatory, Position = 0)]
        [string]
        $NewName
    )

    begin {
        Assert-VmsRequirementsMet
        if (Get-VmsRole -Name $NewName -ErrorAction SilentlyContinue) {
            throw "Role with name '$NewName' already exists."
            return
        }
    }

    process {
        $roleDefinition = $Role | Export-VmsRole -PassThru
        $roleDefinition.Name = $NewName
        $roleDefinition | Import-VmsRole
    }
}
