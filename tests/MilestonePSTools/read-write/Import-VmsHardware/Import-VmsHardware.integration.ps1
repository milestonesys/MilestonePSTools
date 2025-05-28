Context 'Import-VmsHardware' -Skip:($script:SkipReadWriteTests) {
    AfterAll {
        $addresses = Get-ChildItem -Path 'TestDrive:\*.csv' | ForEach-Object {
            Import-Csv -LiteralPath $_.FullName
        } | ForEach-Object {
            ([uribuilder]$_.Address).Uri.ToString()
        }

        foreach ($hw in Get-VmsHardware) {
            if ($hw.Address -in $addresses) {
                $hw | Remove-VmsHardware -Confirm:$false
            }
        }

        $script:Storage | Remove-VmsStorage -Confirm:$false

        foreach ($groupPath in '/Pester Tests', '/Import Group 1', '/Import Group 2') {
            foreach ($deviceType in 'Camera', 'Microphone', 'Speaker', 'Metadata', 'Input', 'Output') {
                Get-VmsDeviceGroup -Path $groupPath -Type $deviceType -ErrorAction SilentlyContinue | Remove-VmsDeviceGroup -Recurse -Confirm:$false
            }
        }
    }

    BeforeAll {
        (Get-VmsManagementServer).RecordingServerFolder.ClearChildrenCache()
        $script:DestinationRecorder = Get-VmsRecordingServer | Select-Object -First 1
        $script:DestinationRecorder.HardwareFolder.ClearChildrenCache()
        $script:Storage = $script:DestinationRecorder | Add-VmsStorage -Name (New-Guid) -Path c:\mediadatabase -Retention (New-TimeSpan -Days 1) -MaximumSizeMB 1024 -ErrorAction Stop
        @(
            [pscustomobject]@{
                Name         = 'Universal Driver (1-camera) 1001'
                Address      = '127.0.0.1:1001'
                DriverNumber = 421
            },
            [pscustomobject]@{
                Name         = 'Universal Driver (1-camera) 1002'
                Address      = '127.0.0.1:1002'
                DriverNumber = 421
            }
        ) | Export-Csv -Path 'TestDrive:\SimpleCsv.csv'
        
        @(
            [pscustomobject]@{
                DeviceType   = 'Camera'
                Name         = 'Universal Driver (1-camera) 2001'
                Address      = 'http://127.0.0.1:2001/'
                Channel      = '0'
                UserName     = 'a'
                Password     = 'a'
                DriverNumber = '421'
                DriverFamily = 'Universal'
                Enabled      = 'True'
                HardwareName = 'Universal Driver (http://127.0.0.1:2001/)'
                StorageName  = 'Local default'
                Coordinates  = '21, 21'
                DeviceGroups = '/Pester Tests;/Import Group 1'
            },
            [pscustomobject]@{
                DeviceType   = 'Camera'
                Name         = 'Universal Driver (1-camera) 2002'
                Address      = 'http://127.0.0.1:2002/'
                Channel      = '0'
                UserName     = 'a'
                Password     = 'a'
                DriverNumber = '421'
                DriverFamily = 'Universal'
                Enabled      = 'False'
                HardwareName = 'Universal Driver (http://127.0.0.1:2002/)'
                StorageName  = $script:Storage.Name
                Coordinates  = '22, 22'
                DeviceGroups = '/Pester Tests;/Import Group 2'
            }
        ) | Export-Csv -Path 'TestDrive:\FullCsv.csv'

        @(
            [pscustomobject]@{
                DeviceType   = 'Camera'
                Name         = 'Universal Driver (1-camera) 2001'
                Address      = 'http://127.0.0.1:2001/'
                Channel      = 'Not a number'
                UserName     = 'a'
                Password     = 'a'
                DriverNumber = '421'
                DriverFamily = 'Universal'
                Enabled      = 'True'
                HardwareName = 'Universal Driver (http://127.0.0.1:2001/)'
                StorageName  = 'Local default'
                Coordinates  = '21, 21'
                DeviceGroups = '/Pester Tests;/Import Group 1'
            },
            [pscustomobject]@{
                DeviceType   = 'Camera'
                Name         = 'Universal Driver (1-camera) 2002'
                Address      = 'http://127.0.0.1:2002/'
                Channel      = 'Not a number'
                UserName     = 'a'
                Password     = 'a'
                DriverNumber = '421'
                DriverFamily = 'Universal'
                Enabled      = 'False'
                HardwareName = 'Universal Driver (http://127.0.0.1:2002/)'
                StorageName  = $script:Storage.Name
                Coordinates  = '22, 22'
                DeviceGroups = '/Pester Tests;/Import Group 2'
            }
        ) | Export-Csv -Path 'TestDrive:\InvalidCsv.csv'
    }

    It 'Can import SimpleCsv' {
        $rows = Import-Csv -Path 'TestDrive:\SimpleCsv.csv'
        $splat = @{
            Path            = 'TestDrive:\SimpleCsv.csv'
            RecordingServer = $script:DestinationRecorder
            Credential      = [pscredential]::new('a', ('a' | ConvertTo-SecureString -AsPlainText -Force))
        }
        $results = Import-VmsHardware @splat
        $results.Count | Should -Be $rows.Count
        for ($rowNum = 0; $rowNum -lt $rows.Count; $rowNum++) {
            $results[$rowNum].Name | Should -BeExactly $rows[$rowNum].Name
            $results[$rowNum].Path | Should -Not -BeNullOrEmpty
            $device = $results[$rowNum] | Get-VmsDevice
            $device | Should -Not -BeNullOrEmpty
            $device.Channel | Should -Be $results[$rowNum].Channel
            ($device | Get-VmsParentItem | Get-VmsParentItem).Path | Should -Be $script:DestinationRecorder.Path
            $device.Enabled | Should -Be $results[$rowNum].Enabled
        }
    }

    It 'Can import FullCsv' {
        $rows = Import-Csv -Path 'TestDrive:\FullCsv.csv'
        $results = Import-VmsHardware -Path 'TestDrive:\FullCsv.csv' -RecordingServer $script:DestinationRecorder
        $results.Count | Should -Be $rows.Count
        for ($rowNum = 0; $rowNum -lt $rows.Count; $rowNum++) {
            # Hardware was successfully added and path of device has been updated in record
            $results[$rowNum].Path | Should -Not -BeNullOrEmpty

            # Can get the device object
            $device = $results[$rowNum] | Get-VmsDevice
            $device | Should -Not -BeNullOrEmpty

            # Device was named correctly
            $device.Name | Should -BeExactly $rows[$rowNum].Name
            
            # Device channel matches expected channel number
            $device.Channel | Should -Be $results[$rowNum].Channel

            # Storage assignment
            $destinationStorage = $script:DestinationRecorder | Get-VmsStorage -Name $rows[$rowNum].StorageName
            $device.RecordingStorage | Should -Be $destinationStorage.Path
            
            # Enabled property was applied correctly
            $device.Enabled | Should -Be $results[$rowNum].Enabled
            
            # Coordinates have been updated as expected
            ($device.GisPoint | ConvertFrom-GisPoint).ToString() | Should -Be $rows[$rowNum].Coordinates
            
            # Device group assignments have been completed
            foreach ($groupPath in $rows[$rowNum].DeviceGroups -split ';') {
                $groupMembers = Get-VmsDeviceGroup -Type $rows[$rowNum].DeviceType -Path $groupPath | Get-VmsDeviceGroupMember -EnableFilter All
                $device.Path -in $groupMembers.Path | Should -Be $true
            }
        }
    }

    It 'Throws a good validation error with a bad Channel value' {
        {
            Import-VmsHardware -Path 'TestDrive:\InvalidCsv.csv' -RecordingServer $script:DestinationRecorder -ErrorVariable importError
        } | Should -Throw -ErrorId 'InvalidValue,ValidateHardwareCsvRows'
    }

    # TODO: Add tests for the following scenarios
    # It 'Can import hardware with DriverNumber' {
    #     throw "Test not implemented"
    # }

    # It 'Can import hardware with DriverFamily' {
    #     throw "Test not implemented"
    # }

    # It 'Can import hardware with out DriverNumber or DriverFamily' {
    #     throw "Test not implemented"
    # }

    # It 'Can update properties of existing hardware' {
    #     throw "Test not implemented"
    # }

    # It 'Can add hardware with https address' {
    #     throw "Test not implemented"
    # }

    # It 'Can add hardware with Address as IP, hostname, IP:port, or fully-qualified URI' {
    #     throw "Test not implemented"
    # }
}
