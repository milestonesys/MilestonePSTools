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

function Get-VmsViewGroupAcl {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    [OutputType([VmsViewGroupAcl])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [ArgumentCompleter([MipItemNameCompleter[ViewGroup]])]
        [MipItemTransformation([ViewGroup])]
        [ViewGroup]
        $ViewGroup,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'FromRole')]
        [ArgumentCompleter([MipItemNameCompleter[Role]])]
        [MipItemTransformation([Role])]
        [Role[]]
        $Role,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'FromRoleId')]
        [VideoOS.Platform.ConfigurationItems.Role]
        $RoleId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'FromRoleName')]
        [ArgumentCompleter([MipItemNameCompleter[Role]])]
        [string]
        $RoleName
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'FromRole' { }
            'FromRoleId' { $Role = Get-VmsRole -Id $RoleId -ErrorAction Stop }
            'FromRoleName' { $Role = Get-VmsRole -Name $RoleName -ErrorAction Stop }
            Default { throw "Unexpected ParameterSetName ""$($PSCmdlet.ParameterSetName)""" }
        }
        if ($Role.Count -eq 0) {
            $Role = Get-VmsRole -RoleType UserDefined
        }
        foreach ($r in $Role) {
            $invokeInfo = $ViewGroup.ChangeSecurityPermissions($r.Path)
            if ($null -eq $invokeInfo) {
                Write-Error "Permissions can not be read or modified on view group ""$($ViewGroup.DisplayName)""."
                continue
            }
            $acl = [VmsViewGroupAcl]@{
                Role               = $r
                Path               = $ViewGroup.Path
                SecurityAttributes = @{}
            }
            foreach ($key in $invokeInfo.GetPropertyKeys()) {
                if ($key -eq 'UserPath') { continue }
                $acl.SecurityAttributes[$key] = $invokeInfo.GetProperty($key)
            }
            Write-Output $acl
        }
    }
}

