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

function Set-VmsBasicUser {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.BasicUser])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.BasicUser]
        $BasicUser,

        [Parameter()]
        [SecureStringTransformAttribute()]
        [securestring]
        $Password,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [BoolTransformAttribute()]
        [bool]
        $CanChangePassword,

        [Parameter()]
        [BoolTransformAttribute()]
        [bool]
        $ForcePasswordChange,

        [Parameter()]
        [ValidateSet('Enabled', 'LockedOutByAdmin')]
        [string]
        $Status,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            if ($PSCmdlet.ShouldProcess("Basic user '$($BasicUser.Name)'", "Update")) {
                $dirty = $false
                $dirtyPassword = $false
                $initialName = $BasicUser.Name
                foreach ($key in @(($MyInvocation.BoundParameters.GetEnumerator() | Where-Object Key -in $BasicUser.GetPropertyKeys()).Key) + @('Password')) {
                    $newValue = (Get-Variable -Name $key).Value
                    if ($MyInvocation.BoundParameters.ContainsKey('Password') -and $key -eq 'Password') {
                        if ($BasicUser.IsExternal -or -not $BasicUser.CanChangePassword) {
                            Write-Error "Password can not be changed for '$initialName'. IsExternal = $($BasicUser.IsExternal), CanChangePassword = $($BasicUser.CanChangePassword)" -TargetObject $BasicUser
                        } else {
                            Write-Verbose "Updating $key on '$initialName'"
                            $null = $BasicUser.ChangePasswordBasicUser($Password)
                            $dirtyPassword = $true
                        }
                    } elseif ($BasicUser.$key -cne $newValue) {
                        Write-Verbose "Updating $key on '$initialName'"
                        $BasicUser.$key = $newValue
                        $dirty = $true
                    }
                }
                if ($dirty) {
                    $BasicUser.Save()
                } elseif (-not $dirtyPassword) {
                    Write-Verbose "No changes were made to '$initialName'."
                }
            }

            if ($PassThru) {
                $BasicUser
            }
        } catch {
            Write-Error -Message $_.Exception.Message -TargetObject $BasicUser
        }
    }
}

