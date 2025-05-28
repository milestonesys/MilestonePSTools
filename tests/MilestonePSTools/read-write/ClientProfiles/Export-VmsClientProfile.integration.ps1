Context 'Export-VmsClientProfile' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        (Get-VmsManagementServer).ClientProfileFolder.ClearChildrenCache()
        Get-VmsClientProfile -DefaultProfile:$false | Remove-VmsClientProfile
        1..4 | Foreach-Object {
            $null = New-VmsClientProfile -Name "Profile $_" -Description "Profile $_ description"
        }
    }

    It 'Can export all client profiles' {
        $clientProfiles = Get-VmsClientProfile
        $path = Join-Path -Path ([io.path]::GetTempPath()) -ChildPath 'Export-VmsClientProfile1.json'
        try {
            Export-VmsClientProfile -Path $path
            (Get-Content -Path $path -Raw | ConvertFrom-Json).Count | Should -Be $clientProfiles.Count
        } finally {
            Remove-Item -Path $path
        }
    }

    It 'Can export one client profile' {
        $path = Join-Path -Path ([io.path]::GetTempPath()) -ChildPath 'Export-VmsClientProfile2.json'
        try {
            Get-VmsClientProfile -DefaultProfile | Export-VmsClientProfile -Path $path
            (Get-Content -Path $path -Raw | ConvertFrom-Json).Count | Should -Be 1
        } finally {
            Remove-Item -Path $path
        }
    }

    It 'Can export profile by name' {
        $path = Join-Path -Path ([io.path]::GetTempPath()) -ChildPath 'Export-VmsClientProfile3.json'
        try {
            $clientProfile = Get-VmsClientProfile | Get-Random
            Export-VmsClientProfile -ClientProfile $clientProfile.Name -Path $path
            (Get-Content -Path $path -Raw | ConvertFrom-Json).Count | Should -Be 1
        } finally {
            Remove-Item -Path $path
        }
    }

    It 'Can export with ValueTypeInfo' {
        $path = Join-Path -Path ([io.path]::GetTempPath()) -ChildPath 'Export-VmsClientProfile4.json'
        try {
            Get-VmsClientProfile -DefaultProfile | Export-VmsClientProfile -Path $path -ValueTypeInfo
            $obj = (Get-Content -Path $path -Raw | ConvertFrom-Json)[0]
            ($obj.Attributes | Where-Object Namespace -eq 'General').GeneralTitleBar.ValueTypeInfo.Count | Should -BeGreaterThan 0
        } finally {
            Remove-Item -Path $path
        }
    }
}
