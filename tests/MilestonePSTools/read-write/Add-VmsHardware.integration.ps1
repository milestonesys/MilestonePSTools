Context 'Add-VmsHardware' -Skip:($script:SkipReadWriteTests)  {
    It 'Can add universal driver camera' {
        $ProgressPreference = 'SilentlyContinue'
        $hw = $null
        try {
            $rec = Get-RecordingServer | Select-Object -First 1
            $address = [uri]('http://{0}' -f $rec.HostName)
            $rec | Get-VmsHardware | Where-Object { [uri]$_.Address -eq $address } | Remove-Hardware -Confirm:$false
            $cred = [pscredential]::new('a', ('a' | ConvertTo-SecureString -AsPlainText -Force))
            $hw = $rec | Add-VmsHardware -HardwareAddress $address -DriverNumber 421 -Credential $cred
            $hw | Should -Not -BeNullOrEmpty
            $hw.Path | Should -BeLike 'Hardware`[*`]'
        } finally {
            if ($hw) {
                $hw | Remove-Hardware -Confirm:$false
            }
        }
    }
}
