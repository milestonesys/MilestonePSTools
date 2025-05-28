Context 'Get-VmsClientProfileAttributes' -Skip:($script:SkipReadWriteTests)  {
    It 'Can get attributes for all namespaces' {
        (Get-VmsClientProfile -DefaultProfile | Get-VmsClientProfileAttributes).Count | Should -BeGreaterThan 1
    }

    It 'Can get attributes for one namespace' {
        $attributes = Get-VmsClientProfile -DefaultProfile | Get-VmsClientProfileAttributes -Namespace General
        $attributes.Keys.Count | Should -BeGreaterThan 1
        $attributes.Contains('GeneralTitleBar') | Should -BeTrue
    }

    It 'Can get attributes for multiple namespaces' {
        $attributes = Get-VmsClientProfile -DefaultProfile | Get-VmsClientProfileAttributes -Namespace General, Live, Playback
        $attributes.Count | Should -Be 3
        foreach ($attrib in $attributes) {
            $attrib.Keys.Count | Should -BeGreaterThan 1
        }
    }

    It 'ClientProfile parameter accepts a string' {
        $name = (Get-VmsClientProfile -DefaultProfile).Name
        $attributes = Get-VmsClientProfileAttributes -ClientProfile $name -Namespace General
        $attributes.Keys.Count | Should -BeGreaterThan 1
        $attributes.Contains('GeneralTitleBar') | Should -BeTrue
    }
}
