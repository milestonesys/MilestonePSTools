Context 'Set-VmsRole' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        $serverTask = (Get-VmsManagementServer).TimeProfileFolder.AddTimeProfile((New-Guid).ToString(), '', 'Sunclock')
        $script:TimeProfile = [VideoOS.Platform.ConfigurationItems.TimeProfile]::new((Get-VmsManagementServer).ServerId, $serverTask.Path)
        $script:ClientProfile = New-VmsClientProfile -Name (New-Guid).ToString()
        $script:role = New-VmsRole -Name "Set-VmsRole_$(New-Guid)" -PassThru
    }

    It 'Can create role with non-default parameters' {
        $roleParams = @{
            Name                               = "Set-VmsRole_$(New-Guid)"
            Description                        = 'Set-VmsRole Test'
            AllowSmartClientLogOn              = $true
            AllowMobileClientLogOn             = $true
            AllowWebClientLogOn                = $true
            DualAuthorizationRequired          = $true
            MakeUsersAnonymousDuringPTZSession = $true
            ClientLogOnTimeProfile             = $script:TimeProfile
            DefaultTimeProfile                 = $script:TimeProfile
            ClientProfile                      = $script:ClientProfile
        }
        $script:role | Set-VmsRole @roleParams
        $role = Get-VmsRole -Id $script:role.Id

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

    AfterAll {
        Get-VmsRole | Where-Object Name -match '^Set-VmsRole' | Remove-VmsRole -Confirm:$false
        $null = (Get-VmsManagementServer).TimeProfileFolder.RemoveTimeProfile($script:TimeProfile.Path)
        $script:ClientProfile | Remove-VmsClientProfile -Confirm:$false
    }
}
