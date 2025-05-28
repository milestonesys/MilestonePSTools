Context 'Remove-VmsRoleMember' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        $password = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]\{}|;'':",./<>?~'
        $script:BasicUser = New-VmsBasicUser -Name "Remove-VmsRoleMember_$(New-Guid)" -Password $password
        $script:role = New-VmsRole -Name "Remove-VmsRoleMember_$(New-Guid)" -PassThru
    }

    It 'Can remove role member by sid' {
        $script:role | Add-VmsRoleMember -Sid $script:BasicUser.Sid -ErrorAction Stop
        $script:role | Remove-VmsRoleMember -Sid $script:BasicUser.Sid -Confirm:$false
    }

    It 'Can remove role member by user object' {
        $script:role | Add-VmsRoleMember -Sid $script:BasicUser.Sid -ErrorAction Stop
        $user = $script:role | Get-VmsRoleMember | Select-Object -First 1
        $script:role | Remove-VmsRoleMember -User $user -Confirm:$false
    }

    AfterAll {
        Get-VmsRole | Where-Object Name -match '^Remove-VmsRoleMember' | Remove-VmsRole -Confirm:$false
        Get-VmsBasicUser | Where-Object Name -match '^Remove-VmsRoleMember' | Remove-VmsBasicUser -Confirm:$false
    }
}
