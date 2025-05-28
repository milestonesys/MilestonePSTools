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

function ConvertTo-ConfigItemPath {
    [CmdletBinding()]
    [OutputType([videoos.platform.proxy.ConfigApi.ConfigurationItemPath])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path
    )

    process {
        foreach ($p in $Path) {
            try {
                [videoos.platform.proxy.ConfigApi.ConfigurationItemPath]::new($p)
            } catch {
                Write-Error -Message "The value '$p' is not a recognized configuration item path format." -Exception $_.Exception
            }
        }
    }
}

