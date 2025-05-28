Context 'Add-VmsRoleMember' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        $password = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]\{}|;'':",./<>?~'
        $script:BasicUser = New-VmsBasicUser -Name "Add-VmsRoleMember_$(New-Guid)" -Password $password
        $script:WindowsUser = Get-VmsRole -RoleType Adminstrative | Get-VmsRoleMember | Where-Object IdentityType -eq 'WindowsUser' | Select-Object -First 1
        $script:role = New-VmsRole -Name "Add-VmsRoleMember_$(New-Guid)" -PassThru
    }

    It 'Can add basic user by Sid' {
        $script:role | Add-VmsRoleMember -Sid $script:BasicUser.Sid -ErrorAction Stop
        $script:role | Get-VmsRoleMember | Where-Object Sid -eq $script:BasicUser.Sid | Should -Not -BeNullOrEmpty
        $script:role | Remove-VmsRoleMember -Sid $script:BasicUser.Sid -Confirm:$false
    }

    It 'Can add basic user by AccountName' {
        $script:role | Add-VmsRoleMember -AccountName "[BASIC]\$($script:BasicUser.Name)" -ErrorAction Stop
        $script:role | Get-VmsRoleMember | Where-Object Sid -eq $script:BasicUser.Sid | Should -Not -BeNullOrEmpty
        $script:role | Remove-VmsRoleMember -Sid $script:BasicUser.Sid -Confirm:$false
    }

    It 'Can add Windows user by Sid' {
        $script:role | Add-VmsRoleMember -Sid $script:WindowsUser.Sid -ErrorAction Stop
        $script:role | Get-VmsRoleMember | Where-Object Sid -eq $script:WindowsUser.Sid | Should -Not -BeNullOrEmpty
        $script:role | Remove-VmsRoleMember -Sid $script:WindowsUser.Sid -Confirm:$false
    }

    It 'Can add Windows user by AccountName' {
        # This isn't testable when the management server is on a different machine as the account name is attempted to be resolved locally, not remotely.
    }

    AfterAll {
        Get-VmsRole | Where-Object Name -match '^Add-VmsRoleMember' | Remove-VmsRole -Confirm:$false
        Get-VmsBasicUser | Where-Object Name -match '^Add-VmsRoleMember' | Remove-VmsBasicUser -Confirm:$false
    }
}
