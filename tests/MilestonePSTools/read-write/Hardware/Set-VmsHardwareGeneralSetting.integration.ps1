Context 'Set-VmsHardwareGeneralSetting' -Skip:($script:SkipReadWriteTests) {
    It 'Can set FPS' {
        {
            $script:StableFpsHardware | Set-VmsHardwareGeneralSetting -Settings @{
                FPS = 10
            } -ErrorAction Stop
        } | Should -Not -Throw

        $settings = $script:StableFpsHardware | Get-VmsHardwareGeneralSetting
        $settings.FPS | Should -Be 10
    }

    It 'Can set H264 video file' {
        {
            $script:StableFpsHardware | Set-VmsHardwareGeneralSetting -Settings @{
                VideoH264Files = '_1920x1080_30_5_shoes_short'
            } -ErrorAction Stop
        } | Should -Not -Throw
        $settings = $script:StableFpsHardware | Get-VmsHardwareGeneralSetting
        $settings.VideoH264Files | Should -Be '_1920x1080_30_5_shoes_short'
    }
}