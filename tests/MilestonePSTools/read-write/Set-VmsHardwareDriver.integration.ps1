Context 'Set-VmsHardwareDriver' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        $rs = Get-VmsRecordingServer | Select-Object -First 1
        $hwParams = @{
            HardwareAddress = 'http://{0}:{1}' -f $rs.HostName, (Get-Random -Minimum 1 -Maximum 65536)
            Credential      = [pscredential]::new('a', ('a' | ConvertTo-SecureString -AsPlainText -Force))
            DriverNumber    = 5000
            SkipConfig      = $true
            ErrorAction     = 'Stop'
        }
        $script:hw = $rs | Add-VmsHardware @hwParams | Set-VmsHardware -Enabled $true -PassThru
        Start-Sleep -Seconds 5
    }

    AfterAll {
        $script:hw | Remove-VmsHardware -Confirm:$false
    }

    It 'Can replace hardware without changing driver' {
        if ([version](Get-VmsManagementServer).Version -ge '23.1') {
            {
                $script:hw | Set-VmsHardwareDriver -PassThru -Confirm:$false -ErrorAction Stop
            } | Should -Not -Throw
        } else {
            $true | Should -BeTrue
        }
    }
}
