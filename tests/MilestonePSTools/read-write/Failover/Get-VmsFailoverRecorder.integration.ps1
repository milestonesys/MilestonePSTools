Context 'Get-VmsFailoverRecorder' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            Get-VmsFailoverGroup | Remove-VmsFailoverGroup -Confirm:$false -Force
            Get-VmsFailoverRecorder -HotStandby | Set-VmsFailoverRecorder -Unassigned -Confirm:$false
        }
    }

    AfterAll {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            Get-VmsFailoverGroup | Remove-VmsFailoverGroup -Confirm:$false -Force
            Get-VmsFailoverRecorder -HotStandby | Set-VmsFailoverRecorder -Unassigned -Confirm:$false
        }
    }

    It 'Can get all failover recorders' {
        if (-not (Test-VmsLicensedFeature 'RecordingServerFailover')) {
            $null | Should -BeNullOrEmpty -Because "RecordingServerFailover feature is not licensed."
        } elseif ((Get-VmsFailoverRecorder -Recurse).Count -eq 0) {
            $null | Should -BeNullOrEmpty -Because "There are no failover recording servers."
        } else {
            (Get-VmsFailoverRecorder -Recurse).Count | Should -BeGreaterThan 0
        }
    }

    It 'Can get failover recorders from group' {
        if (-not (Test-VmsLicensedFeature 'RecordingServerFailover')) {
            $null | Should -BeNullOrEmpty -Because "RecordingServerFailover feature is not licensed."
        } elseif ((Get-VmsFailoverRecorder -Recurse).Count -eq 0) {
            $null | Should -BeNullOrEmpty -Because "There are no failover recording servers."
        } else {
            $group = New-VmsFailoverGroup -Name 'Test Group'
            Get-VmsFailoverRecorder -Unassigned | Foreach-Object {
                $group | Add-VmsFailoverRecorder -FailoverRecorder $_
            }
            $group.ClearChildrenCache()
            ($group | Get-VmsFailoverRecorder).Count | Should -BeGreaterThan 0
        }
    }

    It 'Can get hotstandby failover recorders' {
        if (-not (Test-VmsLicensedFeature 'RecordingServerFailover')) {
            $null | Should -BeNullOrEmpty -Because "RecordingServerFailover feature is not licensed."
        } elseif ((Get-VmsFailoverRecorder -Recurse).Count -eq 0) {
            $null | Should -BeNullOrEmpty -Because "There are no failover recording servers."
        } else {
            Get-VmsFailoverRecorder -Recurse | Set-VmsFailoverRecorder -Unassigned -Confirm:$false
            $fo = Get-VmsFailoverRecorder -Unassigned | Select-Object -First 1
            $rs = Get-VmsRecordingServer | Select-Object -First 1
            $rs | Set-VmsRecordingServer -HotStandby $fo -Confirm:$false
            (Get-VmsFailoverRecorder -HotStandby).Count | Should -Be 1
        }
    }
}
