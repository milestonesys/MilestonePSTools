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

function Find-VmsVideoOSItem {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.Item])]
    [RequiresVmsConnection()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [string[]]
        $SearchText,

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $MaxCount = [int]::MaxValue,

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $MaxSeconds = 30,

        [Parameter()]
        [ArgumentCompleter([KindArgumentCompleter])]
        [KindNameTransform()]
        [guid]
        $Kind,

        [Parameter()]
        [VideoOS.Platform.FolderType]
        $FolderType
    )

    begin {
        Assert-VmsRequirementsMet
        $config = [VideoOS.Platform.Configuration]::Instance
    }

    process {
        foreach ($text in $SearchText) {
            $result = [VideoOS.Platform.SearchResult]::OK
            $items = $config.GetItemsBySearch($text, $MaxCount, $MaxSeconds, [ref]$result)

            foreach ($item in $items) {
                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Kind') -and $item.FQID.Kind -ne $Kind) {
                    continue
                }
                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('FolderType') -and $FolderType -ne $item.FQID.FolderType) {
                    continue
                }
                $item
            }

            if ($result -ne [VideoOS.Platform.SearchResult]::OK) {
                Write-Warning "Search result: $result"
            }
        }
    }
}
