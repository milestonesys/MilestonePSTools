Context 'Set-VmsHardware' -Skip:($script:SkipReadWriteTests) {
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
        if ($script:hw) {

        }
    }

    It 'Can change all settings' {
        { $script:hw | Set-VmsHardware -Enabled $true -ErrorAction Stop } | Should -Not -Throw
        $script:hw = Get-VmsHardware -Id $script:hw.Id
        $hwParams = @{
            Hardware             = $script:hw
            Enabled              = $true
            Name                 = 'Set-VmsHardware -Name'
            Address              = [uri]'http://set-vmshardware/'
            UserName             = 'powershell'
            Password             = 'P0werSh3ll' | ConvertTo-SecureString -AsPlainText -Force
            UpdateRemoteHardware = $true
            Description          = 'Set-VmsHardware -Description'
            PassThru             = $true
            ErrorAction          = 'Stop'
            Confirm              = $false
        }

        # Update the hardware, check all properties, then clear cache and get a fresh
        # copy from the management server and check all properties again.
        $updatedHw = Set-VmsHardware @hwParams
        for ($i = 0; $i -lt 2; $i++) {
            $updatedHw.Enabled | Should -Be $hwParams.Enabled
            $updatedHw.Name | Should -BeExactly $hwParams.Name
            ([uri]$updatedHw.Address) | Should -Be $hwParams.Address
            $updatedHw.UserName | Should -BeExactly $hwParams.UserName
            
            $script:hw | Get-VmsHardwarePassword | Should -BeExactly ([pscredential]::new('a', $hwParams.Password).GetNetworkCredential().Password)
            $updatedHw.Description | Should -BeExactly $hwParams.Description
            Clear-VmsCache
            $updatedHw = Get-VmsHardware -Id $updatedHw.Id
        }
    }

    It 'Is compatible with Set-Hardware syntax' {
        $hwParams = @{
            Hardware    = $script:hw
            NewPassword = 'set-hardwarepassword'
            ErrorAction = 'Stop'
            Confirm     = $false
        }
        Set-HardwarePassword @hwParams
        $script:hw | Get-VmsHardwarePassword | Should -BeExactly $hwParams.NewPassword
    }
}
