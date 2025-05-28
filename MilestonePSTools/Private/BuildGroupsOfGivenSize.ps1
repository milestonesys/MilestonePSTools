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

function BuildGroupsOfGivenSize {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [AllowNull()]
        [object[]]
        $InputObject,

        [Parameter(Mandatory, Position = 0)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $GroupSize,

        [Parameter()]
        [object]
        $EmptyItem = $null,

        [Parameter()]
        [switch]
        $TrimLastGroup

    )

    begin {
        $allObjects = [collections.generic.list[object]]::new()
        $groupOfGroups = [collections.generic.list[[collections.generic.list[object]]]]::new()
    }
    
    process {
        foreach ($obj in $InputObject) {
            $allObjects.Add($obj)
        }
    }
    
    end {
        $index = 0
        do {
            $group = [collections.generic.list[object]]::new()
            for ($i = 0; $i -lt $GroupSize; $i++) {
                $pos = $index + $i
                if ($pos -lt $allObjects.Count) {
                    $group.Add($allObjects[$pos])
                } elseif (!$TrimLastGroup) {
                    $group.Add($EmptyItem)
                }
            }
            $groupOfGroups.Add($group)
            $index += $GroupSize
        } while ($index -lt $allObjects.Count)
        $groupOfGroups
    }
}
