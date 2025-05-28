Context 'Set-VmsFailoverGroup' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            Get-VmsFailoverGroup | Remove-VmsFailoverGroup -Confirm:$false -Force
            Get-VmsFailoverRecorder -Recurse | Set-VmsFailoverRecorder -Unassigned -Confirm:$false
            $script:group = New-VmsFailoverGroup -Name "Initial name" -Description "Initial description"
        }
    }

    AfterAll {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            Get-VmsFailoverGroup | Remove-VmsFailoverGroup -Confirm:$false -Force
        }
    }

    It 'Can rename failover group' {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            ($script:group | Set-VmsFailoverGroup -Name 'New Name' -PassThru).Name | Should -BeExactly 'New Name'
            (Get-VmsManagementServer).FailoverGroupFolder.ClearChildrenCache()
            Get-VmsFailoverGroup -Name 'New Name' | Should -Not -BeNullOrEmpty
        } else {
            $null | Should -BeNullOrEmpty -Because "RecordingServerFailover feature is not licensed."
        }
    }

    It 'Can change failover group description' {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            ($script:group | Set-VmsFailoverGroup -Description 'New Description' -PassThru).Description | Should -BeExactly 'New Description'
            (Get-VmsManagementServer).FailoverGroupFolder.ClearChildrenCache()
            Get-VmsFailoverGroup | Where-Object Description -ceq 'New Description' | Should -Not -BeNullOrEmpty
        } else {
            $null | Should -BeNullOrEmpty -Because "RecordingServerFailover feature is not licensed."
        }
    }

    It 'Can set failover group description to empty string' {
        if (Test-VmsLicensedFeature 'RecordingServerFailover') {
            ($script:group | Set-VmsFailoverGroup -Description '' -PassThru).Description | Should -BeExactly ''
            (Get-VmsManagementServer).FailoverGroupFolder.ClearChildrenCache()
            (Get-VmsFailoverGroup -Id $script:group.Id).Description | Should -BeExactly ''
        } else {
            $null | Should -BeNullOrEmpty -Because "RecordingServerFailover feature is not licensed."
        }
    }
}
