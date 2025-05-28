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

function Remove-VmsRoleMember {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High', DefaultParameterSetName = 'ByUser')]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'ByUser')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'BySid')]
        [Alias('RoleName')]
        [RoleNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.Role[]]
        $Role,

        [Parameter(Mandatory, Position = 1, ParameterSetName = 'ByUser')]
        [VideoOS.Platform.ConfigurationItems.User[]]
        $User,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 2, ParameterSetName = 'BySid')]
        [string[]]
        $Sid
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $removeRoleMember = {
            param($role, $member)
            if ($PSCmdlet.ShouldProcess("$($member.Domain)\$($member.AccountName)", "Remove member from role '$($role.Name)'")) {
                $null = $role.UserFolder.RemoveRoleMember($member.Path)
            }
        }
        foreach ($r in $Role) {
            switch ($PSCmdlet.ParameterSetName) {
                'ByUser' {
                    foreach ($u in $User) {
                        try {
                            $removeRoleMember.Invoke($r, $u)
                        }
                        catch {
                            Write-Error -ErrorRecord $_
                        }
                    }
                }

                'BySid' {
                    foreach ($u in $r | Get-VmsRoleMember | Where-Object Sid -in $Sid) {
                        try {
                            $removeRoleMember.Invoke($r, $u)
                        }
                        catch {
                            Write-Error -ErrorRecord $_
                        }
                    }
                }
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Remove-VmsRoleMember -ParameterName Role -ScriptBlock {
    $values = (Get-VmsRole).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

