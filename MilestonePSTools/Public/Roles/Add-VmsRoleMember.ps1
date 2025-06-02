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

function Add-VmsRoleMember {
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ByAccountName')]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'ByAccountName')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'BySid')]
        [Alias('RoleName')]
        [ValidateNotNull()]
        [ArgumentCompleter([MipItemNameCompleter[Role]])]
        [MipItemTransformation([Role])]
        [Role[]]
        $Role,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 1, ParameterSetName = 'ByAccountName')]
        [string[]]
        $AccountName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 2, ParameterSetName = 'BySid')]
        [string[]]
        $Sid
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ByAccountName') {
            $Sid = $AccountName | ConvertTo-Sid
        }
        foreach ($r in $Role) {
            foreach ($s in $Sid) {
                try {
                    if ($PSCmdlet.ShouldProcess($Role.Name, "Add member with SID $s to role")) {
                        $null = $r.UserFolder.AddRoleMember($s)
                    }
                }
                catch {
                    Write-Error -ErrorRecord $_
                }
            }
        }
    }
}
