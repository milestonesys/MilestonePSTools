Context 'Get-VmsCameraReport' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        $script:camerareport = @()
        $script:expectedColumns = @(
            'Name',
            'Channel',
            'Enabled',
            'ShortName',
            'Shortcut',
            'State',
            'LastModified',
            'Id',
            'IsStarted',
            'IsMotionDetected',
            'IsRecording',
            'IsInOverflow',
            'IsInDbRepair',
            'ErrorWritingGOP',
            'ErrorNotLicensed',
            'ErrorNoConnection',
            'StatusTime',
            'GpsCoordinates',
            'HardwareName',
            'HardwareId',
            'Model',
            'Address',
            'Username',
            'Password',
            'HTTPSEnabled',
            'MAC',
            'Firmware',
            'DriverFamily',
            'Driver',
            'DriverNumber',
            'DriverVersion',
            'DriverRevision',
            'RecorderName',
            'RecorderUri',
            'RecorderId',
            'LiveStream',
            'LiveStreamDescription',
            'LiveStreamMode',
            'ConfiguredLiveResolution',
            'ConfiguredLiveCodec',
            'ConfiguredLiveFPS',
            'CurrentLiveResolution',
            'CurrentLiveCodec',
            'CurrentLiveFPS',
            'CurrentLiveBitrate',
            'RecordedStream',
            'RecordedStreamDescription',
            'RecordedStreamMode',
            'ConfiguredRecordedResolution',
            'ConfiguredRecordedCodec',
            'ConfiguredRecordedFPS',
            'CurrentRecordedResolution',
            'CurrentRecordedCodec',
            'CurrentRecordedFPS',
            'CurrentRecordedBitrate',
            'RecordingEnabled',
            'RecordKeyframesOnly',
            'RecordOnRelatedDevices',
            'PrebufferEnabled',
            'PrebufferSeconds',
            'PrebufferInMemory',
            'RecordingStorageName',
            'RecordingPath',
            'ExpectedRetentionDays',
            'PercentRecordedOneWeek',
            'MediaDatabaseBegin',
            'MediaDatabaseEnd',
            'UsedSpaceInGB',
            'ActualRetentionDays',
            'MeetsRetentionPolicy',
            'MotionEnabled',
            'MotionKeyframesOnly',
            'MotionProcessTime',
            'MotionManualSensitivityEnabled',
            'MotionManualSensitivity',
            'MotionThreshold',
            'MotionMetadataEnabled',
            'MotionExcludeRegions',
            'MotionHardwareAccelerationMode',
            'PrivacyMaskEnabled',
            'Snapshot'
        )
        Get-VmsCamera -EnableFilter All | Set-VmsCamera -Enabled $true -ErrorAction Stop
        Clear-VmsCache
    }

    It 'Completes without error' {
        {
            # Ensure some cameras have recorded video before getting a camera report
            Get-VmsCamera | Select-Object -First 10 | Foreach-Object {
                if (($fqid = [VideoOS.Platform.Configuration]::Instance.GetItem($_.ServerId, $_.Id, [videoos.platform.kind]::Camera).FQID)) {
                    Send-MipMessage -MessageId Control.StartRecordingCommand -DestinationEndpoint $fqid -UseEnvironmentManager
                }
            }
            Start-Sleep -Seconds 10
            $script:camerareport += Get-VmsCameraReport -IncludePlainTextPasswords -IncludeRetentionInfo -IncludeRecordingStats -IncludeSnapshots -SnapshotTimeoutMS 20000 -ErrorAction Stop
        } | Should -Not -Throw
    }

    It 'Has at least one row' {
        $script:camerareport.Count | Should -BeGreaterThan 0
    }

    It 'Has expected columns' {
        $actualColumns = $script:camerareport | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
        foreach ($col in $script:expectedColumns) {
                $col | Should -BeIn $actualColumns -Because "All expected columns should be present in Get-VmsCameraReport results."
        }
        foreach ($col in $actualColumns) {
                $col | Should -BeIn $script:expectedColumns -Because "All columns in Get-VmsCameraReport results should be expected."
        }
    }

    It 'Provides MediaDB Begin and End DateTime properties' {
        $begin = $script:camerareport.MediaDatabaseBegin | Where-Object { $null -ne $_ } | Select-Object -First 1
        $end = $script:camerareport.MediaDatabaseEnd | Where-Object { $null -ne $_ } | Select-Object -First 1
        $begin | Should -BeOfType -ExpectedType [datetime]
        $end | Should -BeOfType -ExpectedType [datetime]
    }

    It 'UsedSpaceInGB has a value' {
        $script:camerareport[0].UsedSpaceInGB | Should -Not -BeNullOrEmpty
        ($script:camerareport[0].UsedSpaceInGB -as [double]) | Should -Not -BeNullOrEmpty
    }

    It 'Has a snapshot' {
        $snapshots = $script:camerareport.Snapshot | Where-Object { $null -ne $_ }
        $snapshots.Count | Should -BeGreaterThan 0
        $snapshots | Select-Object -First 1 | Should -BeOfType -ExpectedType [System.Drawing.Image]
    }
}
