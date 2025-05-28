Context 'Set-VmsClientProfileAttributes' -Skip:($script:SkipReadWriteTests)  {
    It 'Can update single client profile namespace' {
        $clientProfile = Get-VmsClientProfile -DefaultProfile
        $general = $clientProfile | Get-VmsClientProfileAttributes -Namespace General
        $newValue = "C:\$(New-Guid)"
        $general.ApplicationSnapshotPath.Value = $newValue
        $clientProfile | Set-VmsClientProfileAttributes -Attributes $general

        $general = Get-VmsClientProfile -DefaultProfile | Get-VmsClientProfileAttributes -Namespace General
        $general.ApplicationSnapshotPath.Value | Should -BeExactly $newValue

        Clear-VmsCache
        $general = Get-VmsClientProfile -DefaultProfile | Get-VmsClientProfileAttributes -Namespace General
        $general.ApplicationSnapshotPath.Value | Should -BeExactly $newValue
    }

    It 'Can accept attributes as a simple hashtable' {
        $newValue = "C:\$(New-Guid)"
        Get-VmsClientProfile -DefaultProfile | Set-VmsClientProfileAttributes -Namespace General -Attributes (@{ApplicationSnapshotPath = $newValue})

        $general = Get-VmsClientProfile -DefaultProfile | Get-VmsClientProfileAttributes -Namespace General
        $general.ApplicationSnapshotPath.Value | Should -BeExactly $newValue

        Clear-VmsCache
        $general = Get-VmsClientProfile -DefaultProfile | Get-VmsClientProfileAttributes -Namespace General
        $general.ApplicationSnapshotPath.Value | Should -BeExactly $newValue
    }

    It 'Returns an error if Namespace is not defined' {
        $newValue = "C:\$(New-Guid)"
        {
            Get-VmsClientProfile -DefaultProfile | Set-VmsClientProfileAttributes -Attributes (@{ApplicationSnapshotPath = $newValue}) -ErrorAction Stop
        } | Should -Throw
    }

    It 'Can update attribute value and locked state' {
        $general = Get-VmsClientProfile -DefaultProfile | Get-VmsClientProfileAttributes -Namespace General
        $general.ApplicationSnapshotPath.Value = "C:\$(New-Guid)"
        $general.ApplicationSnapshotPath.Locked = !$general.ApplicationSnapshotPath.Value
        Get-VmsClientProfile -DefaultProfile | Set-VmsClientProfileAttributes -Attributes $general

        $updated = Get-VmsClientProfile -DefaultProfile | Get-VmsClientProfileAttributes -Namespace General
        $updated.ApplicationSnapshotPath.Value | Should -BeExactly $general.ApplicationSnapshotPath.Value
        $updated.ApplicationSnapshotPath.Locked | Should -Be $general.ApplicationSnapshotPath.Locked
    }
}
