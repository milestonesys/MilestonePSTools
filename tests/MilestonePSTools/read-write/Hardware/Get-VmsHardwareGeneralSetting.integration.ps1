Context 'Get-VmsHardwareGeneralSetting' -Skip:($script:SkipReadWriteTests) {
    It 'Can get FPS' {
        $settings = $script:StableFpsHardware | Get-VmsHardwareGeneralSetting -ErrorAction Stop
        $settings.FPS | Should -Not -BeNullOrEmpty
    }

    It 'Can get ValueTypeInfo' {
        $info = $script:StableFpsHardware | Get-VmsHardwareGeneralSetting -ValueTypeInfo -ErrorAction Stop
        $info | Should -Not -BeNullOrEmpty
        $info.VideoH264Files.Count | Should -BeGreaterThan 0
        $info.VideoCodec.Count | Should -BeGreaterOrEqual 4
    }
}