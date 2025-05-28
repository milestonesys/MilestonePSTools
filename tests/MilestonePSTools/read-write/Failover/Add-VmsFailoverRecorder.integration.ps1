Context 'Add-VmsFailoverRecorder' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            Get-VmsFailoverGroup | Remove-VmsFailoverGroup -Confirm:$false
            Get-VmsRecordingServer | Set-VmsRecordingServer -DisableFailover -Confirm:$false
        }
    }
    AfterAll {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            Get-VmsFailoverGroup | Remove-VmsFailoverGroup -Confirm:$false -Force
        }
    }

    It 'Can add failover recorder to failover group' {
        if (-not (Test-VmsLicensedFeature 'RecordingServerFailover')) {
            $null | Should -BeNullOrEmpty -Because "RecordingServerFailover feature is not licensed."
        } elseif ((Get-VmsFailoverRecorder -Unassigned).Count -eq 0) {
            $null | Should -BeNullOrEmpty -Because "There are no unassigned failover recording servers."
        } else {
            $fo = Get-VmsFailoverRecorder -Unassigned | Select-Object -First 1
            New-VmsFailoverGroup -Name 'Test Group' | Add-VmsFailoverRecorder $fo
        }
    }
}
