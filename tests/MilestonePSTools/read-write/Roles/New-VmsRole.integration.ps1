Context 'New-VmsRole' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        Get-VmsRole | Where-Object Name -Match '^New-VmsRole' | Remove-VmsRole -Confirm:$false
        $serverTask = (Get-VmsManagementServer).TimeProfileFolder.AddTimeProfile((New-Guid).ToString(), '', 'Sunclock')
        $script:TimeProfile = [VideoOS.Platform.ConfigurationItems.TimeProfile]::new((Get-VmsManagementServer).ServerId, $serverTask.Path)
        $script:ClientProfile = New-VmsClientProfile -Name (New-Guid).ToString()
        $script:Counter = 1
        Clear-VmsCache
    }

    It 'Can create role' {
        $roleName = "New-VmsRole $(($script:Counter++))"
        $role = New-VmsRole -Name $roleName -PassThru

        $role.Name | Should -BeExactly $roleName
        $role.Description | Should -Be ''
        $role.DualAuthorizationRequired | Should -BeFalse
        $role.MakeUsersAnonymousDuringPTZSession | Should -BeFalse
        $role.AllowMobileClientLogOn | Should -BeFalse
        $role.AllowSmartClientLogOn | Should -BeFalse
        $role.AllowWebClientLogOn | Should -BeFalse
        $role.DualAuthorizationRequired | Should -BeFalse
        $role.GetClientTimeProfile().GetProperty('ItemSelection') | Should -Be 'Always'
        $roleProperties = @{}
        ($role | Get-ConfigurationItem).Properties | Foreach-Object {
            $roleProperties[$_.Key] = $_.Value
        }
        $roleProperties.RoleClientLogOnTimeProfile | Should -Be 'TimeProfile[00000000-0000-0000-0000-000000000000]'
        $roleProperties.RoleDefaultTimeProfile | Should -Be 'TimeProfile[11111111-1111-1111-1111-111111111111]'
        $roleProperties.ClientProfile | Should -Be (Get-VmsClientProfile -DefaultProfile).Path
    }

    It 'Can create role with non-default parameters' {
        $roleParams = @{
            Name                               = "New-VmsRole $(($script:Counter++))"
            Description                        = 'New-VmsRole Test'
            AllowSmartClientLogOn              = $true
            AllowMobileClientLogOn             = $true
            AllowWebClientLogOn                = $true
            DualAuthorizationRequired          = $true
            MakeUsersAnonymousDuringPTZSession = $true
            ClientLogOnTimeProfile             = $script:TimeProfile
            DefaultTimeProfile                 = $script:TimeProfile
            ClientProfile                      = $script:ClientProfile
            PassThru                           = $true
        }
        $role = New-VmsRole @roleParams
        Clear-VmsCache
        $role = Get-VmsRole -Id $role.Id

        $role.Name | Should -BeExactly $roleParams.Name
        $role.Description | Should -BeExactly $roleParams.Description
        $role.DualAuthorizationRequired | Should -BeTrue
        $role.MakeUsersAnonymousDuringPTZSession | Should -BeTrue
        $role.AllowMobileClientLogOn | Should -BeTrue
        $role.AllowSmartClientLogOn | Should -BeTrue
        $role.AllowWebClientLogOn | Should -BeTrue
        $role.DualAuthorizationRequired | Should -BeTrue
        $role.GetClientTimeProfile().GetProperty('ItemSelection') | Should -Be $roleParams.ClientLogOnTimeProfile.Name
        $role.RoleClientLogOnTimeProfile | Should -Be $roleParams.ClientLogOnTimeProfile.Path
        $role.RoleDefaultTimeProfile | Should -Be $roleParams.DefaultTimeProfile.Path
        $role.ClientProfile | Should -Be $roleParams.ClientProfile.Path
    }
}
