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

function Export-VmsRole {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipeline)]
        [ArgumentCompleter([MipItemNameCompleter[Role]])]
        [MipItemTransformation([Role])]
        [Role[]]
        $Role,

        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
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
        } elseif (-not $MyInvocation.BoundParameters.ContainsKey('PassThru') -or -not $PassThru.ToBool()) {
            throw "Either or both of Path, or PassThru parameters must be specified."
        }

        $roles = [system.collections.generic.list[pscustomobject]]::new()

        $providers = @{}
        $supportsOidc = [version](Get-VmsManagementServer).Version -ge '22.1'
        if ($supportsOidc) {
            Get-VmsLoginProvider | Foreach-Object {
                $providers[$_.Id] = $_
            }
        }

        $clientProfiles = @{}
        (Get-VmsManagementServer).ClientProfileFolder.ClientProfiles | ForEach-Object {
            if ($null -eq $_) { return }
            $clientProfiles[$_.Path] = $_
        }

        $timeProfiles = @{
            'TimeProfile[11111111-1111-1111-1111-111111111111]' = [pscustomobject]@{
                Name        = 'Always'
                DisplayName = 'Always'
                Path        = 'TimeProfile[11111111-1111-1111-1111-111111111111]'
            }
            'TimeProfile[00000000-0000-0000-0000-000000000000]' = [pscustomobject]@{
                Name        = 'Default'
                DisplayName = 'Default'
                Path        = 'TimeProfile[00000000-0000-0000-0000-000000000000]'
            }
        }
        (Get-VmsManagementServer).TimeProfileFolder.TimeProfiles | ForEach-Object {
            if ($null -eq $_) { return }
            $timeProfiles[$_.Path] = $_
        }
    }

    process {
        if ($Role.Count -eq 0) {
            $Role = Get-VmsRole
        }

        foreach ($r in $Role) {
            $item = $r | Get-ConfigurationItem
            $clientProfile = $item | Get-ConfigurationItemProperty -Key ClientProfile -ErrorAction SilentlyContinue
            if ($clientProfile -and $clientProfiles.ContainsKey($clientProfile)) {
                $clientProfile = $clientProfiles[$clientProfile].Name
            }
            $defaultTimeProfile = $item | Get-ConfigurationItemProperty -Key RoleDefaultTimeProfile -ErrorAction SilentlyContinue
            if ($defaultTimeProfile -and $timeProfiles.ContainsKey($defaultTimeProfile)) {
                $defaultTimeProfile = $timeProfiles[$defaultTimeProfile].Name
            }
            $logonTimeProfile = $item | Get-ConfigurationItemProperty -Key RoleClientLogOnTimeProfile -ErrorAction SilentlyContinue
            if ($logonTimeProfile -and $timeProfiles.ContainsKey($logonTimeProfile)) {
                $logonTimeProfile = $timeProfiles[$logonTimeProfile].Name
            }
            $roleDto = [pscustomobject]@{
                Name                               = $r.Name
                Description                        = $r.Description
                AllowMobileClientLogOn             = $r.AllowMobileClientLogOn
                AllowSmartClientLogOn              = $r.AllowSmartClientLogOn
                AllowWebClientLogOn                = $r.AllowWebClientLogOn
                DualAuthorizationRequired          = $r.DualAuthorizationRequired
                MakeUsersAnonymousDuringPTZSession = $r.MakeUsersAnonymousDuringPTZSession
                ClientProfile                      = $clientProfile
                DefaultTimeProfile                 = $defaultTimeProfile
                ClientLogOnTimeProfile             = $logonTimeProfile
                Claims                             = [system.collections.generic.list[pscustomobject]]::new()
                Users                              = [system.collections.generic.list[pscustomobject]]::new()
                OverallSecurity                    = [system.collections.generic.list[pscustomobject]]::new()
            }
            $r.UserFolder.Users | Foreach-Object {
                $roleDto.Users.Add([pscustomobject]@{
                        Sid          = $_.Sid
                        IdentityType = $_.IdentityType
                        DisplayName  = $_.DisplayName
                        AccountName  = $_.AccountName
                        Domain       = $_.Domain
                    })
            }
            if ($supportsOidc) {
                $r | Get-VmsRoleClaim | ForEach-Object {
                    $roleDto.Claims.Add([pscustomobject]@{
                            LoginProvider = $providers[$_.ClaimProvider].Name
                            ClaimName     = $_.ClaimName
                            ClaimValue    = $_.ClaimValue
                        })
                }
            }
            
            if ($r.RoleType -eq 'UserDefined') {
                $r | Get-VmsRoleOverallSecurity | Sort-Object DisplayName | ForEach-Object {
                    $obj = [ordered]@{
                        DisplayName       = $_.DisplayName
                        SecurityNamespace = $_.SecurityNamespace
                    }
                    foreach ($key in $_.Keys | Where-Object { $_ -notin 'DisplayName', 'SecurityNamespace', 'Role' } | Sort-Object) {
                        $obj[$key] = $_[$key]
                    }
                    $roleDto.OverallSecurity.Add($obj)
                }
            }

            $roles.Add($roleDto)
            if ($PassThru) {
                $roleDto
            }
        }
    }

    end {
        if ($roles.Count -gt 0 -and $Path) {
            [io.file]::WriteAllText($Path, (ConvertTo-Json -InputObject $roles -Depth 10 -Compress), [system.text.encoding]::UTF8)
        }
    }
}
