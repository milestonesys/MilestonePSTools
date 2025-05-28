Context 'Remove-VmsRole' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        $script:role1 = New-VmsRole -Name 'Remove-VmsRole1'
        $script:role2 = New-VmsRole -Name 'Remove-VmsRole2'
        $script:role3 = New-VmsRole -Name 'Remove-VmsRole3'
        $script:role4 = New-VmsRole -Name 'Remove-VmsRole4'
    }

    It 'Can remove role from pipeline' {
        Get-VmsRole | Where-Object Id -eq $script:role1.Id | Should -Not -BeNullOrEmpty
        $script:role1 | Remove-VmsRole -Confirm:$false -ErrorAction Stop
        Get-VmsRole | Where-Object Id -eq $script:role1.Id | Should -BeNullOrEmpty
    }

    It 'Can remove role by named parameter' {
        Get-VmsRole | Where-Object Id -eq $script:role2.Id | Should -Not -BeNullOrEmpty
        Remove-VmsRole -Role $script:role2 -Confirm:$false -ErrorAction Stop
        Get-VmsRole | Where-Object Id -eq $script:role2.Id | Should -BeNullOrEmpty
    }

    It 'Can remove role by named parameter string' {
        Get-VmsRole | Where-Object Id -eq $script:role3.Id | Should -Not -BeNullOrEmpty
        Remove-VmsRole -Role $script:role3.Name -Confirm:$false -ErrorAction Stop
        Get-VmsRole | Where-Object Id -eq $script:role3.Id | Should -BeNullOrEmpty
    }

    It 'Can remove role by Id' {
        Get-VmsRole | Where-Object Id -eq $script:role4.Id | Should -Not -BeNullOrEmpty
        Remove-VmsRole -Id $script:role4.Id -Confirm:$false -ErrorAction Stop
        Get-VmsRole | Where-Object Id -eq $script:role4.Id | Should -BeNullOrEmpty
    }

    AfterAll {
        Get-VmsRole -Name 'Remove-VmsRole*' | Remove-VmsRole -Confirm:$false
    }
}
