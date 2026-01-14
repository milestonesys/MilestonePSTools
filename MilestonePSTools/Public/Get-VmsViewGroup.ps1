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
                [VideoOS.Platform.ConfigurationItems.ViewGroup]::new((Get-VmsSite).FQID.ServerId, "ViewGroup[$Id]")
            } catch [System.Management.Automation.MethodInvocationException] {
                if ($_.FullyQualifiedErrorId -eq 'PathNotFoundMIPException') {
                    Write-Error "No ViewGroup found with ID matching $Id"
                    return
                }
                Write-Error -ErrorRecord $_
            }
            return
        }

        if ($null -ne $Parent) {
            $vgFolder = $Parent.ViewGroupFolder
        } else {
            $vgFolder = (Get-VmsManagementServer).ViewGroupFolder
        }

        $count = 0
        $hasWildcard = $null -ne ($Name | Where-Object { [wildcardpattern]::ContainsWildcardCharacters($_) })

        $queue = [System.Collections.Generic.Queue[VideoOS.Platform.ConfigurationItems.ViewGroup]]::new()
        foreach ($vg in $vgFolder.ViewGroups) {
            $queue.Enqueue($vg)
        }
        while ($queue.Count -gt 0) {
            $vg = $queue.Dequeue()
            foreach ($vgName in $Name) {
                if ($Recurse) {
                    foreach ($child in $vg.ViewGroupFolder.ViewGroups) {
                        $queue.Enqueue($child)
                    }
                }
                if ($vg.DisplayName -like $vgName) {
                    $vg
                    $count++
                }
            }
        }

        if ($count -eq 0 -and -not $hasWildcard) {
            Write-Error "ViewGroup ""$Name"" not found."
        }
    }
}
