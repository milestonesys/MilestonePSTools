Context 'Remove-VmsFailoverRecorder' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            Get-VmsFailoverGroup | Remove-VmsFailoverGroup -Confirm:$false -Force
            Get-VmsFailoverRecorder -Recurse | Set-VmsFailoverRecorder -Unassigned -Confirm:$false
        }
    }

    AfterAll {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            Get-VmsFailoverGroup | Remove-VmsFailoverGroup -Confirm:$false -Force
        }
    }

    It 'Must use -Force to remove failover group with members' {
        if ((Test-VmsLicensedFeature 'RecordingServerFailover') -and (Get-VmsFailoverRecorder -Unassigned)) {
            $group = New-VmsFailoverGroup -Name 'Test Group'
            $group | Add-VmsFailoverRecorder -FailoverRecorder (Get-VmsFailoverRecorder -Unassigned)
            $failoverCount = ($group | Get-VmsFailoverRecorder).Count
            $fo = $group | Get-VmsFailoverRecorder | Select-Object -First 1
            $group | Remove-VmsFailoverRecorder -FailoverRecorder $fo -Confirm:$false
            ($group | Get-VmsFailoverRecorder).Count | Should -Be ($failoverCount - 1)
        } else {
            $null | Should -BeNullOrEmpty -Because "RecordingServerFailover feature is not licensed."
        }
    }
}
