Context 'Get-VmsRole' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        Get-VmsRole -RoleType UserDefined | Remove-VmsRole -Confirm:$false
        $script:roles = @(Get-VmsRole -RoleType Adminstrative) + (1..4 | Foreach-Object {
            New-VmsRole -Name "Get-VmsRole $_" -PassThru
        })
    }

    It 'Can get all roles' {
        (Get-VmsRole).Count | Should -Be 5
    }

    It 'Can get role by Id' {
        $role = Get-VmsRole -Id $script:roles[0].Id -ErrorAction Stop
        $role | Should -Not -BeNullOrEmpty
        $role.Id | Should -BeExactly $script:roles[0].Id
        $role.Name | Should -BeExactly $script:roles[0].Name
    }

    It 'Can get role by Name' {
        $role = Get-VmsRole -Name $script:roles[0].Name -ErrorAction Stop
        $role | Should -Not -BeNullOrEmpty
        $role.Id | Should -BeExactly $script:roles[0].Id
        $role.Name | Should -BeExactly $script:roles[0].Name
    }
}
