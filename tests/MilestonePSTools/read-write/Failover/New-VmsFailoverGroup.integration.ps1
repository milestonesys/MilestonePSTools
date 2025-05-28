Context 'New-VmsFailoverGroup' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            Get-VmsFailoverGroup | Remove-VmsFailoverGroup -Confirm:$false -Force
            1..2 | Foreach-Object {
                $null = New-VmsFailoverGroup -Name "Test Failover Group $_" -Description "Group $_"
            }
        }
    }

    AfterAll {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            Get-VmsFailoverGroup | Remove-VmsFailoverGroup -Confirm:$false -Force
        }
    }

    It 'Can create new failover group' {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            $group = New-VmsFailoverGroup -Name 'Test Group'
            $group.Name | Should -BeExactly 'Test Group'
            Get-VmsFailoverGroup -Name 'Test Group' | Should -Not -BeNullOrEmpty
        } else {
            $null | Should -BeNullOrEmpty -Because "RecordingServerFailover feature is not licensed."
        }
    }

    It 'Cannot reuse existing name' {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            {
                $null = New-VmsFailoverGroup -Name 'Test Group'
            } | Should -Throw -Because 'Failover group names must be unique.'
        } else {
            $null | Should -BeNullOrEmpty -Because "RecordingServerFailover feature is not licensed."
        }
    }
}
