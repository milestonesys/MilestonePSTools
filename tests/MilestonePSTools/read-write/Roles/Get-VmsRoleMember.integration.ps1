Context 'Get-VmsRoleMember' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        (Get-VmsManagementServer).RoleFolder.ClearChildrenCache()
        Get-VmsRole -RoleType UserDefined | Remove-VmsRole -Confirm:$false
        $script:role = New-VmsRole -Name 'Get-VmsRoleMember Test Role' -PassThru
    }

    It 'Can get Adminstrative role members' {
        (Get-VmsRole -RoleType Adminstrative | Get-VmsRoleMember -ErrorAction Stop).Count | Should -BeGreaterThan 0
    }

    It 'Does not return error if role is empty' {
        $script:role | Get-VmsRoleMember -ErrorAction Stop | Should -BeNullOrEmpty
    }
}
