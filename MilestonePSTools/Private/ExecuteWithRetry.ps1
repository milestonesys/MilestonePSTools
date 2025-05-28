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

function ExecuteWithRetry {
    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [scriptblock]
        $ScriptBlock,

        [Parameter()]
        [object[]]
        $ArgumentList = [object[]]::new(0),

        [Parameter()]
        [int]
        $Attempts = 2,

        [Parameter()]
        [switch]
        $ClearVmsCache
    )

    process {
        do {
            try {
                $ScriptBlock.Invoke($ArgumentList)
                break
            } catch {
                if ($Attempts -gt 1) {
                    Write-Verbose "ExecuteWithRetry: Failed with $_"
                    if ($ClearVmsCache) {
                        Clear-VmsCache
                    }
                    Start-Sleep -Milliseconds (Get-Random -Minimum 1000 -Maximum 2000)
                    continue
                }
                throw
            }
        } while ((--$Attempts) -gt 0)
    }
}

