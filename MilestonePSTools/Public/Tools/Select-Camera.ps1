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

function Select-Camera {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresInteractiveSession()]
    param(
        [Parameter()]
        [string]
        $Title = "Select Camera(s)",
        [Parameter()]
        [switch]
        $SingleSelect,
        [Parameter()]
        [switch]
        $AllowFolders,
        [Parameter()]
        [switch]
        $AllowServers,
        [Parameter()]
        [switch]
        $RemoveDuplicates,
        [Parameter()]
        [switch]
        $OutputAsItem
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $items = Select-VideoOSItem -Title $Title -Kind ([VideoOS.Platform.Kind]::Camera) -AllowFolders:$AllowFolders -AllowServers:$AllowServers -SingleSelect:$SingleSelect -FlattenOutput
        $processed = @{}
        if ($RemoveDuplicates) {
            foreach ($item in $items) {
                if ($processed.ContainsKey($item.FQID.ObjectId)) {
                    continue
                }
                $processed.Add($item.FQID.ObjectId, $null)
                if ($OutputAsItem) {
                    Write-Output $item
                }
                else {
                    Get-VmsCamera -Id $item.FQID.ObjectId
                }
            }
        }
        else {
            if ($OutputAsItem) {
                Write-Output $items
            }
            else {
                Write-Output ($items | ForEach-Object { Get-VmsCamera -Id $_.FQID.ObjectId })
            }
        }
    }
}

