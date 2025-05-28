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

function Get-VmsRoleOverallSecurity {
    [CmdletBinding()]
    [OutputType([hashtable])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('RoleName')]
        [RoleNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.Role]
        $Role,

        [Parameter()]
        [SecurityNamespaceTransformAttribute()]
        [guid[]]
        $SecurityNamespace
    )

    begin {
        Assert-VmsRequirementsMet
        $namespacevalues = Get-SecurityNamespaceValues
        if ($SecurityNamespace.Count -eq 0) {
            $SecurityNamespace = $namespacevalues.SecurityNamespacesById.Keys
        }
    }

    process {
        if ($Role.RoleType -ne 'UserDefined') {
            Write-Error 'Overall security settings do not apply to the Administrator role.'
            return
        }

        try {
            foreach ($namespace in $SecurityNamespace) {
                $response = $Role.ChangeOverallSecurityPermissions($namespace)
                $result = @{
                    Role        = $Role.Path
                    DisplayName = $namespacevalues.SecurityNamespacesById[$namespace]
                }
                foreach ($key in $response.GetPropertyKeys()) {
                    $result[$key] = $response.GetProperty($key)
                }
                # :: milestonesystemsinc/powershellsamples/issue-81
                # Older VMS versions may not include a SecurityNamespace value
                # in the ChangeOverallSecurityPermissions properties which means
                # you can't pass this hashtable into Set-VmsRoleOverallSecurity
                # without explicity including the namespace parameter. So we'll
                # manually add it here just in case it's not already set.
                $result['SecurityNamespace'] = $namespace.ToString()
                $result
            }
        } catch {
            Write-Error -ErrorRecord $_
        }
    }
}


Register-ArgumentCompleter -CommandName Get-VmsRoleOverallSecurity -ParameterName Role -ScriptBlock {
    $values = ((Get-VmsManagementServer).RoleFolder.Roles | Where-Object RoleType -EQ 'UserDefined').Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

Register-ArgumentCompleter -CommandName Get-VmsRoleOverallSecurity -ParameterName SecurityNamespace -ScriptBlock {
    $values = (Get-SecurityNamespaceValues).SecurityNamespacesByName.Keys | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

