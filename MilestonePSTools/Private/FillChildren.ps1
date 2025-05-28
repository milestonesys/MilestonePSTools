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

function FillChildren {
    [CmdletBinding()]
    [OutputType([VideoOS.ConfigurationApi.ClientService.ConfigurationItem])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.ConfigurationApi.ClientService.ConfigurationItem]
        $ConfigurationItem,

        [Parameter()]
        [int]
        $Depth = 1
    )

    process {
        $stack = New-Object System.Collections.Generic.Stack[VideoOS.ConfigurationApi.ClientService.ConfigurationItem]
        $stack.Push($ConfigurationItem)
        while ($stack.Count -gt 0) {
            $Depth = $Depth - 1
            $item = $stack.Pop()
            $item.Children = $item | Get-ConfigurationItem -ChildItems
            $item.ChildrenFilled = $true
            if ($Depth -gt 0) {
                $item.Children | Foreach-Object {
                    $stack.Push($_)
                }
            }
        }
        Write-Output $ConfigurationItem
    }
}

