Context 'Get-VmsHardwarePassword' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        $rs = Get-VmsRecordingServer | Select-Object -First 1
        $hwParams = @{
            HardwareAddress = 'http://{0}:{1}' -f $rs.HostName, (Get-Random -Minimum 1 -Maximum 65536)
            Credential      = [pscredential]::new('a', ('Get-VmsHardwarePassword' | ConvertTo-SecureString -AsPlainText -Force))
            DriverNumber    = 421
            SkipConfig      = $true
            ErrorAction     = 'Stop'
        }
        $script:hw = $rs | Add-VmsHardware @hwParams
    }

    It 'Can read hardware password' {
        $script:hw | Get-VmsHardwarePassword | Should -BeExactly 'Get-VmsHardwarePassword'
    }

    It 'Can read hardware password using alias' {
        $script:hw | Get-HardwarePassword | Should -BeExactly 'Get-VmsHardwarePassword'
    }
}
