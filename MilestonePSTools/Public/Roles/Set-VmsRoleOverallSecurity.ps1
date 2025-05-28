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

function Set-VmsRoleOverallSecurity {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([hashtable])]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('RoleName')]
        [RoleNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.Role]
        $Role,

        [Parameter(ValueFromPipelineByPropertyName)]
        [SecurityNamespaceTransformAttribute()]
        [guid]
        $SecurityNamespace,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [hashtable]
        $Permissions
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($null -eq $Role) {
            $roleId = Split-VmsConfigItemPath -Path $Permissions.Role
            if ([string]::IsNullOrEmpty($roleId)) {
                Write-Error "Role must be provided either using the Role parameter, or by including a key of 'Role' in the Permissions hashtable with the Configuration Item path of an existing role."
                return
            }
            $Role = Get-VmsRole -Id $roleId
        }

        if ($Role.RoleType -eq 'Adminstrative') {
            Write-Error 'Overall security settings do not apply to the Administrator role.'
            return
        }

        if (-not $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('SecurityNamespace') -and $null -eq ($SecurityNamespace = $Permissions.SecurityNamespace -as [guid])) {
            Write-Error "SecurityNamespace must be provided either using the SecurityNamespace parameter, or by including a key of 'SecurityNamespace' in the Permissions hashtable with a GUID value matching the ID of an existing overall security namespace."
            return
        }

        try {
            $invokeInfo = $Role.ChangeOverallSecurityPermissions($SecurityNamespace)
            $attributes = @{}
            $invokeInfo.GetPropertyKeys() | ForEach-Object { $attributes[$_] = $invokeInfo.GetProperty($_) }
            if ($attributes.Count -eq 0) {
                Write-Error "No security attribute key/value pairs were returned for namespace ID '$SecurityNamespace'." -TargetObject $invokeInfo
                return
            }
            $dirty = $false
            foreach ($key in $Permissions.Keys) {
                if ($key -in 'DisplayName', 'SecurityNamespace', 'Role') {
                    continue
                }
                if (-not $attributes.ContainsKey($key)) {
                    Write-Warning "Attribute '$key' not found in SecurityNamespace"
                    continue
                } elseif ($attributes[$key] -cne $Permissions[$key]) {
                    if ($PSCmdlet.ShouldProcess($Role.Name, "Set $key to $($Permissions[$key])")) {
                        $invokeInfo.SetProperty($key, $Permissions[$key])
                        $dirty = $true
                    }
                }
            }
            if ($dirty) {
                $null = $invokeInfo.ExecuteDefault()
            }
        } catch [VideoOS.Platform.Proxy.ConfigApi.ValidateResultException] {
            $_ | HandleValidateResultException -TargetObject $Role
        } catch {
            Write-Error -ErrorRecord $_
        }
    }
}


Register-ArgumentCompleter -CommandName Set-VmsRoleOverallSecurity -ParameterName Role -ScriptBlock {
    $values = ((Get-VmsManagementServer).RoleFolder.Roles | Where-Object RoleType -EQ 'UserDefined').Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

Register-ArgumentCompleter -CommandName Set-VmsRoleOverallSecurity -ParameterName SecurityNamespace -ScriptBlock {
    $values = (Get-SecurityNamespaceValues).SecurityNamespacesByName.Keys | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

