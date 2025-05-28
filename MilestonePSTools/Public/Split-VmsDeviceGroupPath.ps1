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

function Split-VmsDeviceGroupPath {
    [CmdletBinding()]
    [OutputType([string[]])]
    [RequiresVmsConnection($false)]
    param (
        # Specifies a device group path in unix directory form with forward-slashes as separators.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline, Position = 0)]
        [string]
        $Path
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        <#
        Path separator   = /
        Escape character = `
        Steps:
            1. Remove unescaped leading and trailing path separator characters
            2. Split path string on unescaped path separators
            3. In each path part, replace the `/ character sequence with /
        #>
        $Path.TrimStart('/') -replace '(?<!`)/$', '' -split '(?<!`)/' | Foreach-Object { $_ -replace '`/', '/' } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    }
}

