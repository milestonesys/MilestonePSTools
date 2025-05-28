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

function Set-VmsRole {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.Role])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [RoleNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.Role[]]
        $Role,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [switch]
        $AllowSmartClientLogOn,

        [Parameter()]
        [switch]
        $AllowMobileClientLogOn,

        [Parameter()]
        [switch]
        $AllowWebClientLogOn,

        [Parameter()]
        [switch]
        $DualAuthorizationRequired,

        [Parameter()]
        [switch]
        $MakeUsersAnonymousDuringPTZSession,

        [Parameter()]
        [Alias('RoleClientLogOnTimeProfile')]
        [TimeProfileNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.TimeProfile]
        $ClientLogOnTimeProfile,

        [Parameter()]
        [Alias('RoleDefaultTimeProfile')]
        [TimeProfileNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.TimeProfile]
        $DefaultTimeProfile,

        [Parameter()]
        [ClientProfileTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.ClientProfile]
        $ClientProfile,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $dirty = $false
        foreach ($r in $Role) {
            try {
                foreach ($property in $r | Get-Member -MemberType Property | Where-Object Definition -like '*set;*' | Select-Object -ExpandProperty Name) {
                    $parameterName = $property
                    switch ($property) {
                        # We would just use the $property variable, but these properties are prefixed with "Role" which is
                        # redundant and doesn't match the New-VmsRole function.
                        'RoleClientLogOnTimeProfile' { $parameterName = 'ClientLogOnTimeProfile' }
                        'RoleDefaultTimeProfile'     { $parameterName = 'DefaultTimeProfile' }
                    }
                    if (-not $PSBoundParameters.ContainsKey($parameterName)) {
                        continue
                    }

                    $newValue = $PSBoundParameters[$parameterName]
                    if ($parameterName -like '*Profile') {
                        $newValue = $newValue.Path
                    }
                    if ($PSBoundParameters[$parameterName] -ceq $r.$property) {
                        continue
                    }
                    if ($PSCmdlet.ShouldProcess($r.Name, "Set $property to $($PSBoundParameters[$parameterName])")) {
                        $r.$property = $newValue
                        $dirty = $true
                    }
                }

                if ($MyInvocation.BoundParameters.ContainsKey('ClientProfile') -and $PSCmdlet.ShouldProcess($r.Name, "Set ClientProfile to $($ClientProfile.Name)")) {
                    try {
                        $serverTask = $r.SetClientProfile($ClientProfile.Path)
                        if ($serverTask.State -ne 'Success') {
                            Write-Error -Message "Failed to update ClientProfile. $($serverTask.ErrorText)" -TargetObject $r
                        }
                    } catch {
                        Write-Error -Message $_.Exception.Message -Exception $_.Exception -TargetObject $r
                    }
                }

                if ($dirty) {
                    $r.Save()
                }
                if ($PassThru) {
                    $r
                }
            } catch {
                Write-Error -Message $_.Exception.Message -Exception $_.Exception -TargetObject $r
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Set-VmsRole -ParameterName Role -ScriptBlock {
    $values = (Get-VmsRole).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

Register-ArgumentCompleter -CommandName Set-VmsRole -ParameterName DefaultTimeProfile -ScriptBlock {
    $values = @('Always')
    (Get-VmsManagementServer).TimeProfileFolder.TimeProfiles.Name | Sort-Object | Foreach-Object {
        $values += $_
    }
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

Register-ArgumentCompleter -CommandName Set-VmsRole -ParameterName ClientLogOnTimeProfile -ScriptBlock {
    $values = @('Always')
    (Get-VmsManagementServer).TimeProfileFolder.TimeProfiles.Name | Sort-Object | Foreach-Object {
        $values += $_
    }
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

Register-ArgumentCompleter -CommandName Set-VmsRole -ParameterName ClientProfile -ScriptBlock {
    $values = (Get-VmsClientProfile).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

