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

function Import-VmsRole {
    [CmdletBinding(DefaultParameterSetName = 'Path', SupportsShouldProcess)]
    [RequiresVmsConnection()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'InputObject')]
        [object[]]
        $InputObject,

        [Parameter(Mandatory, ParameterSetName = 'Path')]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $Force,

        [Parameter()]
        [switch]
        $RemoveUndefinedClaims,

        [Parameter()]
        [switch]
        $RemoveUndefinedUsers
    )

    begin {
        Assert-VmsRequirementsMet
        $null = Get-VmsManagementServer -ErrorAction Stop

        if ($MyInvocation.BoundParameters.ContainsKey('Path')) {
            $resolvedPath = (Resolve-Path -Path $Path -ErrorAction SilentlyContinue -ErrorVariable rpError).Path
            if ([string]::IsNullOrWhiteSpace($resolvedPath)) {
                $resolvedPath = $rpError.TargetObject
            }
            $Path = $resolvedPath
            $fileInfo = [io.fileinfo]$Path
            if (-not $fileInfo.Directory.Exists) {
                throw ([io.directorynotfoundexception]::new("Directory not found: $($fileInfo.Directory.FullName)"))
            }
            if (($fi = [io.fileinfo]$Path).Extension -ne '.json') {
                Write-Verbose "A .json file extension will be added to the file '$($fi.Name)'"
                $Path += ".json"
            }
        }


        $roles = @{}
        (Get-VmsManagementServer).RoleFolder.ClearChildrenCache()
        Get-VmsRole | Foreach-Object {
            if ($roles.ContainsKey($_.Name)) {
                throw "There are multiple existing roles with the same case-insensitive name '$($_.Name)'. The VMS may allow this, but this cmdlet does not. Please consider renaming roles so that they all have unique names."
            }
            $roles[$_.Name] = $_
        }

        

        $providers = @{}
        $supportsOidc = [version](Get-VmsManagementServer).Version -ge '22.1'
        if ($supportsOidc) {
            Get-VmsLoginProvider | Foreach-Object {
                if ($null -eq $_) { return }
                $providers[$_.Name] = $_
            }
        }

        $clientProfiles = @{}
        (Get-VmsManagementServer).ClientProfileFolder.ClientProfiles | ForEach-Object {
            if ($null -eq $_) { return }
            $clientProfiles[$_.Name] = $_
        }

        $timeProfiles = @{
            'Always' = [pscustomobject]@{
                Name        = 'Always'
                DisplayName = 'Always'
                Path        = 'TimeProfile[11111111-1111-1111-1111-111111111111]'
            }
            'Default' = [pscustomobject]@{
                Name        = 'Default'
                DisplayName = 'Default'
                Path        = 'TimeProfile[00000000-0000-0000-0000-000000000000]'
            }
        }
        (Get-VmsManagementServer).TimeProfileFolder.TimeProfiles | ForEach-Object {
            if ($null -eq $_) { return }
            $timeProfiles[$_.Name] = $_
        }

        $basicUsers = @{}
        Get-VmsBasicUser -External:$false | ForEach-Object {
            $basicUsers[$_.Name] = $_
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            $InputObject = [io.file]::ReadAllText($Path, [text.encoding]::UTF8) | ConvertFrom-Json -ErrorAction Stop
        }

        foreach ($dto in $InputObject) {
            if ([string]::IsNullOrWhiteSpace($dto.Name)) {
                Write-Error -Message "Record does not have a 'Name' property, the minimum required information to create a new role." -TargetObject $dto
                continue
            }
            $role = $roles[$dto.Name]
            if ($role -and -not $Force) {
                Write-Warning "Role '$($dto.Name)' already exists. To import changes to existing roles, use the -Force switch."
                continue
            }

            $roleParams = @{
                ErrorAction = 'Stop'
            }
            foreach ($propertyName in 'Name', 'Description', 'AllowSmartClientLogOn', 'AllowMobileClientLogOn', 'AllowWebClientLogOn', 'DualAuthorizationRequired', 'MakeUsersAnonymousDuringPTZSession', 'ClientLogOnTimeProfile', 'DefaultTimeProfile', 'ClientProfile') {
                $propertyValue = $dto.$propertyName
                if ($propertyName -in @('DefaultTimeProfile', 'ClientLogOnTimeProfile')) {
                    if ($propertyValue -ne 'Always' -and $propertyValue -ne 'Default') {
                        # The default "Always" and "<default>" time profiles are not actually a time profile defined in (Get-VmsManagementServer).TimeProfileFolder.TimeProfiles
                        # but the TimeProfileNameTransformAttribute class will accept 'Always' or 'Default' as a value and mock up a TimeProfile object for us.
                        $propertyValue = $timeProfiles[$propertyValue]
                    }
                }
                if ($propertyName -eq 'ClientProfile' -and -not $clientProfiles.ContainsKey($dto.ClientProfile)) {
                    $propertyValue = $null
                }
                if ($null -ne $propertyValue -or $propertyName -eq 'Description') {
                    $roleParams[$propertyName] = $propertyValue
                } else {
                    Write-Warning "Skipping property '$propertyName'. Unable to resolve the value '$($dto.$propertyName)'."
                }
            }

            # Create/update the main role properties
            if ($role) {
                $roleParams.Role = $role
                $roleParams.PassThru = $true
                $role = Set-VmsRole @roleParams
            }
            else {
                $role = New-VmsRole @roleParams
            }

            # Update overall security for all roles except default admin role
            if ($role.RoleType -eq 'UserDefined') {
                foreach ($definition in $dto.OverallSecurity) {
                    $permissions = $definition
                    if ($permissions -isnot [System.Collections.IDictionary]) {
                        $permissions = @{}
                        ($definition | Get-Member -MemberType NoteProperty).Name | ForEach-Object {
                            $permissions[$_] = $definition.$_
                        }
                    }
                    $role | Set-VmsRoleOverallSecurity -Permissions $permissions
                }
            }

            # Update the role members, and claims
            if ($supportsOidc) {
                $existingClaims = @()
                $role | Get-VmsRoleClaim | ForEach-Object {
                    $existingClaims += $_
                }
                foreach ($claim in $dto.Claims) {
                    if ([string]::IsNullOrWhiteSpace($claim.LoginProvider) -or -not $providers.ContainsKey($claim.LoginProvider)) {
                        Write-Warning "Skipping claim '$($claim.ClaimName)'. Unable to resolve LoginProvider value '$($claim.LoginProvider)'."
                        continue
                    }
                    $provider = $providers[$claim.LoginProvider]
                    $registeredClaims = ($provider | Get-VmsLoginProviderClaim).Name
                    if ($claim.ClaimName -notin $registeredClaims) {
                        Write-Verbose "Adding '$($claim.ClaimName)' as a new registered claim."
                        $provider | Add-VmsLoginProviderClaim -Name $claim.ClaimName
                    }
                    if ($null -eq ($existingClaims | Where-Object {$_.ClaimProvider -eq $provider.Id -and $_.ClaimName -eq $claim.ClaimName -and $_.ClaimValue -eq $claim.ClaimValue })) {
                        $role | Add-VmsRoleClaim -LoginProvider $provider -ClaimName $claim.ClaimName -ClaimValue $claim.ClaimValue
                        $existingClaims += [pscustomobject]@{
                            ClaimProvider = $provider.Id
                            ClaimName     = $claim.ClaimName
                            ClaimValue    = $claim.ClaimValue
                        }
                    }
                }
                if ($RemoveUndefinedClaims) {
                    foreach ($claim in $existingClaims) {
                        $provider = Get-VmsLoginProvider | Where-Object Id -eq $claim.ClaimProvider
                        $definedClaims = $dto.Claims | Where-Object { $_.LoginProvider -eq $provider.Name -and $_.ClaimName -eq $claim.ClaimName -and $_.ClaimValue -eq $claim.ClaimValue }
                        if ($null -eq $definedClaims) {
                            $role | Remove-VmsRoleClaim -LoginProvider $provider -ClaimName $claim.ClaimName -ClaimValue $claim.ClaimValue
                        }
                    }
                }
            }

            $existingUsers = @{}
            $role | Get-VmsRoleMember | ForEach-Object {
                $existingUsers[$_.Sid] = $null
            }
            foreach ($user in $dto.Users) {
                if ($user.Sid -and -not $existingUsers.ContainsKey($user.Sid)) {
                    if ($user.IdentityType -eq 'BasicUser') {
                        if ($basicUsers.ContainsKey($user.AccountName)) {
                            $user.Sid = $basicUsers[$user.AccountName].Sid
                        } else {
                            try {
                                $passwordChars = [System.Web.Security.Membership]::GeneratePassword(26, 10).ToCharArray() + (Get-Random -Minimum 1000 -Maximum 10000).ToString().ToCharArray()
                                $randomPassword = [securestring]::new()
                                ($passwordChars | Get-Random -Count ($passwordChars.Length)) | ForEach-Object { $randomPassword.AppendChar($_) }
                                $newUser = New-VmsBasicUser -Name $user.AccountName -Password $randomPassword -Status LockedOutByAdmin
                                $basicUsers[$newUser.Name] = $newUser
                                $user.Sid = $newUser.Sid
                            } finally {
                                0..($passwordChars.Length - 1) | ForEach-Object { $passwordChars[$_] = 0 }
                                Remove-Variable -Name passwordChars
                            }
                        }
                    }
                    $role | Add-VmsRoleMember -Sid $user.Sid
                    $existingUsers[$user.Sid] = $null
                }
            }
            if ($RemoveUndefinedUsers) {
                foreach ($sid in $existingUsers.Keys | Where-Object { $_ -notin $dto.Users.Sid}) {
                    $role | Remove-VmsRoleMember -Sid $sid
                }
            }

            $role
        }
    }
}

