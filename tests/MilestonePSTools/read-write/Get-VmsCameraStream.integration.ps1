Context 'Get-VmsCameraStream' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        $script:StableFpsHardware = Get-VmsHardware -Name 'MilestonePSTools.Tests'
        $script:streams = $script:StableFpsHardware | Get-VmsCamera | Select-Object -First 1 | Get-VmsCameraStream
    }

    It 'Has a stream' {
        $script:streams.Count | Should -BeGreaterThan 0
    }

    It 'Has one Recorded stream' {
        ($script:streams | Where-Object Recorded).Count | Should -Be 1
    }

    It 'Has one default live stream' {
        ($script:streams | Where-Object LiveDefault).Count | Should -Be 1
    }
}
