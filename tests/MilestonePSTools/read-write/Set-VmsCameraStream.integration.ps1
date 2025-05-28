Context 'Set-VmsCameraStream' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        $script:StableFpsHardware = Get-VmsHardware -Name 'MilestonePSTools.Tests'
        $script:streams = $script:StableFpsHardware | Get-VmsCamera -Channel 0 | Get-VmsCameraStream
        $stream1 = $script:streams | Select-Object -First 1
        $stream1 | Set-VmsCameraStream -RecordingTrack Primary -PlaybackDefault -LiveDefault -LiveMode WhenNeeded -DisplayName $stream1.Name
        $script:streams | Select-Object -Skip 1 | Set-VmsCameraStream -Disabled
    }

    It 'Can rename stream' {
        $camera = $script:StableFpsHardware | Get-VmsCamera -Channel 0
        $stream = $camera | Get-VmsCameraStream -LiveDefault

        $oldName = $stream.DisplayName
        $newName = 'Live Stream {0}' -f (New-Guid)

        # Change stream display name and verify change on the original object
        $stream | Set-VmsCameraStream -DisplayName $newName
        $stream.DisplayName | Should -BeExactly $newName

        # Clear the config api cache, retrieve the stream again, and verify change again.
        $camera.ClearChildrenCache()
        $stream = $camera | Get-VmsCameraStream -LiveDefault
        $stream.DisplayName | Should -BeExactly $newName

        # Revert to old name
        $stream | Set-VmsCameraStream -DisplayName $oldName
        $stream.DisplayName | Should -BeExactly $oldName
    }

    It 'Can add and remove a stream usage' {
        # Stage
        $camera = $script:StableFpsHardware | Get-VmsCamera -Channel 0
        $streams = $camera | Get-VmsCameraStream
        $oldLiveStream = $streams | Where-Object LiveDefault
        $oldStreamCount = ($streams | Where-Object Enabled).Count

        # Test
        $stream = $streams | Where-Object Enabled -EQ $false | Select-Object -First 1
        $newStreamName = 'New Live Stream ({0})' -f (Get-Date).Ticks
        $stream | Set-VmsCameraStream -LiveDefault -DisplayName $newStreamName -LiveMode Always
        ($streams | Where-Object Enabled).Count | Should -Be ($oldStreamCount + 1)

        # Test after clearing cached config
        $camera.ClearChildrenCache()
        $streams = $camera | Get-VmsCameraStream
        $stream = $streams | Where-Object DisplayName -EQ $newStreamName
        $stream | Should -Not -BeNullOrEmpty
        $stream.DisplayName | Should -BeExactly $newStreamName
        $stream.LiveMode | Should -BeExactly 'Always'
        $stream.LiveDefault | Should -BeTrue

        $oldLiveStream = $streams | Where-Object Name -EQ $oldLiveStream.Name
        $oldLiveStream | Should -Not -BeNullOrEmpty
        $oldLiveStream.LiveDefault | Should -BeFalse

        # Cleanup
        $oldLiveStream | Set-VmsCameraStream -LiveDefault -RecordingTrack Primary -PlaybackDefault -LiveMode WhenNeeded -ErrorAction Stop
        $stream | Set-VmsCameraStream -Disabled -ErrorAction Stop
    }

    It 'Can enable and disable all streams at once' {
        $camera = $script:StableFpsHardware | Get-VmsCamera -Channel 0

        # Enable all streams
        {
            $camera | Get-VmsCameraStream | Set-VmsCameraStream -LiveMode WhenNeeded -ErrorAction Stop
        } | Should -Not -Throw
            ($camera | Get-VmsCameraStream | Where-Object Enabled -EQ $false).Count | Should -Be 0 -Because 'All streams should be enabled with LiveMode "WhenNeeded"'

        # Disable all streams except one
        $camera | Get-VmsCameraStream -LiveDefault | Set-VmsCameraStream -RecordingTrack Primary -PlaybackDefault
        $camera | Get-VmsCameraStream | Where-Object LiveDefault -EQ $false | Set-VmsCameraStream -Disabled
            ($camera | Get-VmsCameraStream -Enabled).Count | Should -Be 1
    }

    It 'Can change stream settings' {
        $camera = $script:StableFpsHardware | Get-VmsCamera -Channel 0
        $streams = $camera | Get-VmsCameraStream
        $newResolution = '432x321'
        $oldResolution = '555x333'


        $streams | Set-VmsCameraStream -Settings @{ Resolution = $newResolution }

        $streams | ForEach-Object {
            $_.Settings.Resolution | Should -Be $newResolution
        }

        $camera.ClearChildrenCache()
        $streams = $camera | Get-VmsCameraStream
        $streams | ForEach-Object {
            $_.Settings.Resolution | Should -Be $newResolution
        }

        $streams | Set-VmsCameraStream -Settings @{ Resolution = $oldResolution }
    }
}
