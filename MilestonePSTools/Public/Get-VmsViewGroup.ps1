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

function Get-VmsViewGroup {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.ViewGroup])]
    param (
        [Parameter(ValueFromPipeline, ParameterSetName = 'Default')]
        [VideoOS.Platform.ConfigurationItems.ViewGroup]
        $Parent,

        [Parameter(ParameterSetName = 'Default', Position = 1)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [ArgumentCompleter([MipItemNameCompleter[ViewGroup]])]
        [string[]]
        $Name = '*',

        [Parameter(ParameterSetName = 'Default')]
        [switch]
        $Recurse,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 2)]
        [guid]
        $Id
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            try {
                $vg = [VideoOS.Platform.ConfigurationItems.ViewGroup]::new((Get-VmsSite).FQID.ServerId, "ViewGroup[$Id]")
                Write-Output $vg
            } catch [System.Management.Automation.MethodInvocationException] {
                if ($_.FullyQualifiedErrorId -eq 'PathNotFoundMIPException') {
                    Write-Error "No ViewGroup found with ID matching $Id"
                    return
                }
            }
        } else {
            if ($null -ne $Parent) {
                $vgFolder = $Parent.ViewGroupFolder
            } else {
                $vgFolder = (Get-VmsManagementServer).ViewGroupFolder
            }

            $count = 0
            $hasWildcard = $false
            foreach ($n in $Name) {
                if ([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($n)) {
                    $hasWildcard = $true
                    break
                }
            }

            if ($Recurse) {
                $queue = [System.Collections.Generic.Queue[VideoOS.Platform.ConfigurationItems.ViewGroup]]::new()
                foreach ($vg in $vgFolder.ViewGroups) {
                    $queue.Enqueue($vg)
                }

                while ($queue.Count -gt 0) {
                    $vg = $queue.Dequeue()
                    foreach ($n in $Name) {
                        if ($vg.DisplayName -notlike $n) {
                            continue
                        }
                        $count++
                        Write-Output $vg
                        break
                    }

                    $childFolder = $vg.ViewGroupFolder
                    if ($null -ne $childFolder) {
                        foreach ($child in $childFolder.ViewGroups) {
                            $queue.Enqueue($child)
                        }
                    }
                }
            } else {
                foreach ($vg in $vgFolder.ViewGroups) {
                    foreach ($n in $Name) {
                        if ($vg.DisplayName -notlike $n) {
                            continue
                        }
                        $count++
                        Write-Output $vg
                        break
                    }
                }
            }

            if ($count -eq 0 -and -not $hasWildcard) {
                Write-Error "ViewGroup ""$Name"" not found."
            }
        }
    }
}
