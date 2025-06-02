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

function New-VmsRole {
    [CmdletBinding(SupportsShouldProcess)]
    [Alias('Add-Role')]
    [OutputType([VideoOS.Platform.ConfigurationItems.Role])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        $AllowSmartClientLogOn,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        $AllowMobileClientLogOn,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        $AllowWebClientLogOn,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        $DualAuthorizationRequired,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        $MakeUsersAnonymousDuringPTZSession,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('RoleClientLogOnTimeProfile')]
        [ArgumentCompleter([MipItemNameCompleter[TimeProfile]])]
        [MipItemTransformation([TimeProfile])]
        [TimeProfile]
        $ClientLogOnTimeProfile,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('RoleDefaultTimeProfile')]
        [ArgumentCompleter([MipItemNameCompleter[TimeProfile]])]
        [MipItemTransformation([TimeProfile])]
        [TimeProfile]
        $DefaultTimeProfile,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ArgumentCompleter([MipItemNameCompleter[ClientProfile]])]
        [MipItemTransformation([ClientProfile])]
        [ClientProfile]
        $ClientProfile,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            $ms = Get-VmsManagementServer -ErrorAction Stop
            if (-not $PSCmdlet.ShouldProcess("$($ms.Name) ($($ms.ServerId.Uri))", "Create role '$Name'")) {
                return
            }

            $serverTask = $ms.RoleFolder.AddRole(
                $Name, $Description,
                $DualAuthorizationRequired,
                $MakeUsersAnonymousDuringPTZSession,
                $AllowMobileClientLogOn, $AllowSmartClientLogOn, $AllowWebClientLogOn,
                $DefaultTimeProfile.Path, $ClientLogOnTimeProfile.Path)

            if ($serverTask.State -ne 'Success') {
                throw "RoleFolder.AddRole(..) state: $($serverTask.State). Error: $($serverTask.ErrorText)"
            }

            $newRole = [VideoOS.Platform.ConfigurationItems.Role]::new($ms.ServerId, $serverTask.Path)
            if ($MyInvocation.BoundParameters.ContainsKey('ClientProfile')) {
                $newRole | Set-VmsRole -ClientProfile $ClientProfile
            }

            <#
                TFS 540814 / 577523: On 2022 R2 and earlier, time profile paths were ignored during role creation and you needed to set these after creating the role.
            #>
            $dirty = $false
            if ($MyInvocation.BoundParameters.ContainsKey('ClientLogOnTimeProfile') -and $newRole.RoleClientLogOnTimeProfile -ne $ClientLogOnTimeProfile.Path) {
                $newRole.RoleClientLogOnTimeProfile = $ClientLogOnTimeProfile.Path
                $dirty = $true
            }
            if ($MyInvocation.BoundParameters.ContainsKey('DefaultTimeProfile') -and $newRole.RoleDefaultTimeProfile -ne $DefaultTimeProfile.Path) {
                $newRole.RoleDefaultTimeProfile = $DefaultTimeProfile.Path
                $dirty = $true
            }
            if ($dirty) {
                $null = $newRole.Save()
            }


            $newRole
            if ($PassThru) {
                Write-Verbose "NOTICE: The PassThru parameter is deprecated as of MilestonePSTools v23.1.2. The new role is now always returned."
            }
        } catch {
            if ($_.Exception.Message) {
                Write-Error -Message $_.Exception.Message -Exception $_.Exception
            } else {
                Write-Error -ErrorRecord $_
            }
        }
    }
}
