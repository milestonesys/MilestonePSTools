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

function Split-VmsConfigItemPath {
    [CmdletBinding(DefaultParameterSetName = 'Id')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'Id')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'ItemType')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'ParentItemType')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [string[]]
        $Path,

        [Parameter(ParameterSetName = 'Id')]
        [switch]
        $Id,

        [Parameter(ParameterSetName = 'ItemType')]
        [switch]
        $ItemType,

        [Parameter(ParameterSetName = 'ParentItemType')]
        [switch]
        $ParentItemType
    )
        
    process {
        if ($null -eq $Path) { $Path = '' }
        foreach ($record in $Path) {
            try {
                [videoos.platform.proxy.ConfigApi.ConfigurationItemPath]::new($record).($PSCmdlet.ParameterSetName)
            } catch {
                throw
            }
        }
    }
}
