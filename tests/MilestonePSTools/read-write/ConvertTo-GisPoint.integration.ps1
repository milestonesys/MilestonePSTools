Context 'ConvertTo-GisPoint' -Skip:($script:SkipReadWriteTests)  {
    It 'Converts string coordinates correctly' {
        $gisPoint = ConvertTo-GisPoint -Coordinates '45.4171310677097, -122.7320429689'
        $gisPoint | Should -Be 'POINT (-122.7320429689 45.4171310677097)'

        $gisPoint = ConvertTo-GisPoint -Coordinates '45.4171310677097, -122.7320429689, 125'
        $gisPoint | Should -Be 'POINT (-122.7320429689 45.4171310677097 125)'
    }

    It 'Throws on invalid coordinates' {
        {
            ConvertTo-GisPoint -Coordinates '45.4171310677097, -122.7320429689, 1, 1' -ErrorAction Stop
        } | Should -Throw
    }

    It 'Can update GisPoint property of camera' {
        # Setup
        $camera = Get-VmsHardware | Get-VmsCamera | Select-Object -First 1
        $oldGisPoint = $camera.GisPoint
        $c1 = '45.4171310677097, -122.7320429689'
        $newGisPoint = ConvertTo-GisPoint -Coordinates $c1

        # Test
        { $camera | Set-VmsCamera -GisPoint $newGisPoint -ErrorAction Stop } | Should -Not -Throw
        $camera.GisPoint | Should -Be $newGisPoint
        # Verify GisPoint is still correct when retrieving a fresh copy of camera settings from server
        $camera = Get-VmsCamera -Id $camera.Id
        $camera.GisPoint | Should -Be $newGisPoint

        # Cleanup
        { $camera | Set-VmsCamera -GisPoint $oldGisPoint -ErrorAction Stop } | Should -Not -Throw
        $camera.GisPoint | Should -Be $oldGisPoint
    }
}
