Context 'Export-VmsHardware' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        $script:ExportPath = Join-Path 'TestDrive:' 'ExportVmsHardware'
        $null = New-Item -Path $script:ExportPath -ItemType Directory -Force
    }

    AfterAll {
        if (Test-Path $script:ExportPath) {
            Remove-Item -Path $script:ExportPath -Recurse -Force
        }
    }

    It 'Can export hardware to CSV' {
        $csvPath = Join-Path $script:ExportPath 'hardware.csv'
        Export-VmsHardware -Path $csvPath -ErrorAction Stop
        Test-Path $csvPath | Should -Be $true
        $rows = Import-Csv -LiteralPath $csvPath
        $rows.Count | Should -BeGreaterThan 0
    }

    It 'Can export hardware to Excel' {
        $xlsxPath = Join-Path $script:ExportPath 'hardware.xlsx'
        Export-VmsHardware -Path $xlsxPath -ErrorAction Stop
        Test-Path $xlsxPath | Should -Be $true
        (Get-Item $xlsxPath).Length | Should -BeGreaterThan 0
    }

    It 'Loads the embedded ImportExcel module when exporting to Excel' {
        # Remove any previously loaded ImportExcel module to force re-import from embedded path
        Remove-Module ImportExcel -Force -ErrorAction SilentlyContinue
        $xlsxPath = Join-Path $script:ExportPath 'hardware_embedded.xlsx'
        Export-VmsHardware -Path $xlsxPath -ErrorAction Stop
        Test-Path $xlsxPath | Should -Be $true

        $importExcel = Get-Module ImportExcel
        $importExcel | Should -Not -BeNullOrEmpty
        $importExcel.ModuleBase | Should -BeLike '*modules*ImportExcel*'
    }
}
