Context 'Get-VmsFailoverGroup' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            Get-VmsFailoverGroup | Remove-VmsFailoverGroup -Confirm:$false -Force
            1..2 | Foreach-Object {
                $null = New-VmsFailoverGroup -Name "Test Failover Group $_" -Description "Group $_"
            }
        }
    }

    AfterAll {
        Get-VmsFailoverGroup | Remove-VmsFailoverGroup -Confirm:$false -Force
    }

    It 'Can get all failover groups' {
        $groups = Get-VmsFailoverGroup
        $groups.Count | Should -BeExactly 2
        (Get-VmsManagementServer).FailoverGroupFolder.FailoverGroups.Count | Should -BeExactly 2
    }

    It 'Can get failover group by Name' {
        $group = Get-VmsFailoverGroup -Name 'Test Failover Group 1' -ErrorAction Stop
        $group.Count | Should -Be 1
        $group | Should -Not -BeNullOrEmpty
        $group.Name | Should -BeExactly 'Test Failover Group 1'
    }

    It 'Can get failover group by Id' {
        $id = (Get-VmsManagementServer).FailoverGroupFolder.FailoverGroups[0].Id
        $group = Get-VmsFailoverGroup -Id $id -ErrorAction Stop
        $group.Count | Should -Be 1
        $group | Should -Not -BeNullOrEmpty
    }
}
