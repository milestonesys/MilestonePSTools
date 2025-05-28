Context 'Read and write device settings' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        $script:HW = $null
        $script:GetCommands = 'Get-VmsCamera', 'Get-VmsMicrophone', 'Get-VmsSpeaker', 'Get-VmsMetadata', 'Get-VmsInput', 'Get-VmsOutput'
        $script:GetCommandAliases = $script:GetCommands | Foreach-Object { $_ -replace 'Vms' }

        $ProgressPreference = 'SilentlyContinue'
        try {
            $rec = Get-RecordingServer | Select-Object -First 1
            $address = [uri]('http://{0}' -f $rec.HostName)
            $rec | Get-VmsHardware | Where-Object { [uri]$_.Address -eq $address } | Remove-Hardware -Confirm:$false
            $cred = [pscredential]::new('a', ('a' | ConvertTo-SecureString -AsPlainText -Force))
            $script:hw = $rec | Add-VmsHardware -HardwareAddress $address -DriverNumber 5000 -Credential $cred -ErrorAction Stop
        } catch {
            throw
        }
    }

    AfterAll {
        $script:HW | Remove-VmsHardware -Confirm:$false
    }

    Describe 'ParameterSet:QueryItems' {
        It 'Can get all devices' {
            foreach ($command in $script:GetCommands) {
                $devices = Invoke-Expression "$command -EnableFilter All -ErrorAction Stop"
                $devices.Count | Should -BeGreaterThan 0
            }
        }

        It 'EnableFilter:Enabled' {
            foreach ($command in $script:GetCommands) {
                $setCommand = $command -replace '^Get', 'Set'
                Invoke-Expression "$command -EnableFilter All | $setCommand -Enabled `$true"
                $devices = Invoke-Expression "$command -ErrorAction Stop"
                $devices.Count | Should -BeGreaterThan 0
                ($devices | Where-Object Enabled).Count | Should -BeGreaterThan 0
            }
        }

        It 'EnableFilter:Disabled' {
            foreach ($command in $script:GetCommands) {
                $setCommand = $command -replace '^Get', 'Set'
                Invoke-Expression "$command -EnableFilter All | $setCommand -Enabled `$false"
                $devices = Invoke-Expression "$command -EnableFilter Disabled -ErrorAction Stop"
                $devices.Count | Should -BeGreaterThan 0
                ($devices | Where-Object Enabled -eq $false).Count | Should -BeGreaterThan 0
            }
        }

        It 'Can query by Name' {
            foreach ($command in $script:GetCommands) {
                $device = Invoke-Expression "$command -EnableFilter All | Select-Object -First 1"
                $result = Invoke-Expression "$command -EnableFilter All -Name '$($device.Name.Substring(0, 4))'"
                $result | Should -Not -BeNullOrEmpty
            }
        }

        It 'Can query by Channel' {
            foreach ($command in $script:GetCommands) {
                $result = Invoke-Expression "$command -EnableFilter All -Channel 0"
                $result | Should -Not -BeNullOrEmpty
                $result | ForEach-Object {
                    $_.Channel | Should -Be 0
                }
            }
        }
    }

    Describe 'ParameterSet:Hardware' {
        It 'Can get all devices' {
            foreach ($command in $script:GetCommands) {
                $devices = Invoke-Expression "Get-VmsHardware -Id $($script:HW.Id) | $command -EnableFilter All -ErrorAction Stop"
                $devices.Count | Should -BeGreaterThan 0
            }
        }

        It 'EnableFilter:Enabled' {
            foreach ($command in $script:GetCommands) {
                $setCommand = $command -replace '^Get', 'Set'
                Invoke-Expression "$command -EnableFilter All | $setCommand -Enabled `$true"
                $devices = Invoke-Expression "Get-VmsHardware -Id $($script:HW.Id) | $command -ErrorAction Stop"
                $devices.Count | Should -BeGreaterThan 0
                ($devices | Where-Object Enabled).Count | Should -BeGreaterThan 0
            }
        }

        It 'EnableFilter:Disabled' {
            foreach ($command in $script:GetCommands) {
                $setCommand = $command -replace '^Get', 'Set'
                Invoke-Expression "$command -EnableFilter All | $setCommand -Enabled `$false"
                $devices = Invoke-Expression "Get-VmsHardware -Id $($script:HW.Id) | $command -EnableFilter Disabled -ErrorAction Stop"
                $devices.Count | Should -BeGreaterThan 0
                ($devices | Where-Object Enabled -eq $false).Count | Should -BeGreaterThan 0
            }
        }

        It 'Can query by Name' {
            foreach ($command in $script:GetCommands) {
                $device = Invoke-Expression "Get-VmsHardware -Id $($script:HW.Id) | $command -EnableFilter All | Select-Object -First 1"
                $result = Invoke-Expression "Get-VmsHardware -Id $($script:HW.Id) | $command -EnableFilter All -Name '$($device.Name.Substring(0, 4))'"
                $result | Should -Not -BeNullOrEmpty
            }
        }

        It 'Can query by Channel' {
            foreach ($command in $script:GetCommands) {
                $result = Invoke-Expression "Get-VmsHardware -Id $($script:HW.Id) | $command -EnableFilter All -Channel 0"
                $result | Should -Not -BeNullOrEmpty
                $result.Channel | Should -Be 0
            }
        }
    }

    Describe 'ParameterSet:Id' {
        It 'Can get all devices' {
            foreach ($command in $script:GetCommands) {
                $devices = Invoke-Expression "Get-VmsHardware -Id $($script:HW.Id) | $command -EnableFilter All -ErrorAction Stop"
                $devicesById = Invoke-Expression "$command -Id $($devices.Id -join ', ')"
                $devicesById.Count | Should -BeGreaterThan 0
                $devicesById.Count | Should -Be $devices.Count
            }
        }

        It 'Throws on a bad id' {
            {
                Get-VmsDevice -Id (New-Guid) -ErrorAction Stop
            } | Should -Throw
        }

        It 'Throws a meaningful error on a bad id' {
            Get-VmsDevice -Id (New-Guid) -ErrorAction SilentlyContinue -ErrorVariable itemNotFoundError
            $itemNotFoundError.Exception.GetType().FullName | Should -Be 'System.Management.Automation.ItemNotFoundException'
            $itemNotFoundError.Exception.Message | Should -Match '^No device found with the specified Id of ''.+?''\.$'
        }

        It 'Returns valid devices despite a bad id' {
            $goodId = (Get-VmsCamera -EnableFilter All | Select-Object -First 1).Id
            $badId = New-Guid
            $devices = Get-VmsDevice -Id $goodId, $badId -ErrorAction SilentlyContinue
            $devices.Count | Should -Be 1
            $devices[0].Id | Should -Be $goodId
        }
    }

    Describe 'ParameterSet:Path' {
        It 'Can get all devices' {
            foreach ($command in $script:GetCommands) {
                $devices = Invoke-Expression "Get-VmsHardware -Id $($script:HW.Id) | $command -EnableFilter All -ErrorAction Stop"
                $devicesByPath = Invoke-Expression "$command -Path $($devices.Path -join ', ')"
                $devicesByPath.Count | Should -BeGreaterThan 0
                $devicesByPath.Count | Should -Be $devices.Count
            }
        }

        It 'Throws on a bad path' {
            {
                Get-VmsDevice -Path "Camera[$(New-Guid)]" -ErrorAction Stop
            } | Should -Throw
        }

        It 'Throws a meaningful error on a bad path' {
            Get-VmsDevice -Path "Camera[$(New-Guid)]" -ErrorAction SilentlyContinue -ErrorVariable itemNotFoundError
            $itemNotFoundError.Exception.GetType().FullName | Should -Be 'System.Management.Automation.ItemNotFoundException'
            $itemNotFoundError.Exception.Message | Should -Match '^No device found with the specified Path of ''.+?''\.$'
        }

        It 'Returns valid devices despite a bad path' {
            $good = (Get-VmsCamera -EnableFilter All | Select-Object -First 1).Path
            $bad = 'Camera[{0}]' -f (New-Guid)
            $devices = Get-VmsDevice -Path $good, $bad -ErrorAction SilentlyContinue
            $devices.Count | Should -Be 1
            $devices[0].Path | Should -Be $good
        }
    }

    Describe 'Set' {
        It 'Can set all camera properties' {
            $splat = @{
                RecordKeyframesOnly           = $true
                RecordingFramerate            = 4
                RecordOnRelatedDevices        = $false
                RecordingEnabled              = $true
                ManualRecordingTimeoutEnabled = $true
                ManualRecordingTimeoutMinutes = 7
                PrebufferEnabled              = $true
                PrebufferSeconds              = 9
                PrebufferInMemory             = $false
                EdgeStorageEnabled            = $true
                EdgeStoragePlaybackEnabled    = $true
                Name                          = 'Pester Test {0}' -f (New-Guid)
                ShortName                     = 'Pester Test'
                Description                   = 'Pester Test Camera Description'
                Enabled                       = $true
                GisPoint                      = 'POINT (45 -45)'
                CoverageDirection             = 0.25
                CoverageFieldOfView           = 0.125
                CoverageDepth                 = 75
                PassThru                      = $true
            }
            $device = $script:HW | Get-VmsCamera -EnableFilter All | Select-Object -First 1 | Set-VmsCamera @splat
            $device | Should -Not -BeNullOrEmpty
            $device = Get-VmsCamera -Id $device.Id
            $splat.Remove('PassThru')
            foreach ($kvp in $splat.GetEnumerator()) {
                $device.($kvp.Key) | Should -Be $kvp.Value
            }
        }
    }
}
