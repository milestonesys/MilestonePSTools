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

function Get-VmsVideoOSItem {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.Item])]
    [RequiresVmsConnection()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'GetItemByFQID')]
        [VideoOS.Platform.FQID]
        $Fqid,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'GetItem')]
        [VideoOS.Platform.ServerId]
        $ServerId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'GetItem')]
        [guid]
        $Id,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'GetItem')]
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'GetItems')]
        [KindNameTransformAttribute()]
        [guid]
        $Kind,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'GetItems')]
        [VideoOS.Platform.ItemHierarchy]
        $ItemHierarchy = [VideoOS.Platform.ItemHierarchy]::SystemDefined,

        [Parameter(ParameterSetName = 'GetItems')]
        [VideoOS.Platform.FolderType]
        $FolderType
    )

    begin {
        Assert-VmsRequirementsMet
        $config = [VideoOS.Platform.Configuration]::Instance
    }

    process {
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'GetItemByFQID' {
                    $config.GetItem($Fqid)
                }

                'GetItem' {
                    if ($ServerId) {
                        $config.GetItem($ServerId, $Id, $Kind)
                    } else {
                        $config.GetItem($Id, $Kind)
                    }
                }

                'GetItems' {
                    $checkKind = $false
                    $checkFolderType = $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('FolderType')

                    $stack = [system.collections.generic.stack[VideoOS.Platform.Item]]::new()
                    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Kind')) {
                        $checkKind = $true
                        $config.GetItemsByKind($Kind, $ItemHierarchy) | Foreach-Object {
                            if ($null -ne $_) {
                                $stack.Push($_)
                            }
                        }
                    } else {
                        $config.GetItems($ItemHierarchy) | Foreach-Object {
                            if ($null -ne $_) {
                                $stack.Push($_)
                            }
                        }
                    }
                    while ($stack.Count -gt 0) {
                        $item = $stack.Pop()
                        if (-not $checkKind -or $item.FQID.Kind -eq $Kind) {
                            if (-not $checkFolderType -or $item.FQID.FolderType -eq $FolderType) {
                                $item
                            }
                        }
                        if ($item.HasChildren -ne 'No') {
                            $item.GetChildren() | ForEach-Object {
                                $stack.Push($_)
                            }
                        }
                    }
                }
                Default {
                    throw "ParameterSet '$_' not implemented."
                }
            }
        } catch {
            Write-Error -ErrorRecord $_
        }
    }
}

Register-ArgumentCompleter -CommandName Get-VmsVideoOSItem -ParameterName Kind -ScriptBlock {
    $values = ([videoos.platform.kind].DeclaredMembers | Where-Object { $_.MemberType -eq 'Field' -and $_.FieldType -eq [guid] }).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

