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

function Set-VmsViewGroupAcl {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VmsViewGroupAcl[]]
        $ViewGroupAcl
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        foreach ($acl in $ViewGroupAcl) {
            $path = [VideoOS.Platform.Proxy.ConfigApi.ConfigurationItemPath]::new($acl.Path)
            $viewGroup = Get-VmsViewGroup -Id $path.Id
            $target = "View group ""$($viewGroup.DisplayName)"""
            if ($PSCmdlet.ShouldProcess($target, "Updating security permissions for role $($acl.Role.Name)")) {
                $invokeInfo = $viewGroup.ChangeSecurityPermissions($acl.Role.Path)
                $dirty = $false
                foreach ($key in $acl.SecurityAttributes.Keys) {
                    $newValue = $acl.SecurityAttributes[$key]
                    $currentValue = $invokeInfo.GetProperty($key)
                    if ($newValue -cne $currentValue -and $PSCmdlet.ShouldProcess($target, "Changing $key from $currentValue to $newValue")) {
                        $invokeInfo.SetProperty($key, $newValue)
                        $dirty = $true
                    }

                }
                if ($dirty -and $PSCmdlet.ShouldProcess($target, "Saving security permission changes for role $($acl.Role.Name)")) {
                    $invokeResult = $invokeInfo.ExecuteDefault()
                    if ($invokeResult.State -ne 'Success') {
                        Write-Error $invokeResult.ErrorText
                    }
                }
            }
        }
    }
}

