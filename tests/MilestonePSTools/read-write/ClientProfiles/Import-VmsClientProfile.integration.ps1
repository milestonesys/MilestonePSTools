Context 'Import-VmsClientProfile' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        (Get-VmsManagementServer).ClientProfileFolder.ClearChildrenCache()
        Get-VmsClientProfile -DefaultProfile:$false | Remove-VmsClientProfile
        1..4 | Foreach-Object {
            $null = New-VmsClientProfile -Name "Profile $_" -Description "Profile $_ description"
        }
    }

    It 'Can update existing client profiles' {
        foreach ($clientProfile in Get-VmsClientProfile) {
            $clientProfile | Set-VmsClientProfileAttributes -Namespace General -Attributes (@{ApplicationSnapshotPath = "C:\$($clientProfile.Name)"})
        }

        $path = Join-Path -Path ([io.path]::GetTempPath()) -ChildPath 'Import-VmsClientProfile1.json'
        try {
            Export-VmsClientProfile -Path $path
            foreach ($clientProfile in Get-VmsClientProfile) {
                $clientProfile | Set-VmsClientProfileAttributes -Namespace General -Attributes (@{ApplicationSnapshotPath = "C:\$(New-Guid)"})
            }
            $null = Import-VmsClientProfile -Path $path -Force
            (Get-VmsManagementServer).ClientProfileFolder.ClearChildrenCache()
            foreach ($clientProfile in Get-VmsClientProfile) {
                ($clientProfile | Get-VmsClientProfileAttributes -Namespace General).ApplicationSnapshotPath.Value | Should -BeExactly "C:\$($clientProfile.Name)"
            }
        } finally {
            Remove-Item -Path $path
        }
    }

    It 'Can recreate client profiles' {
        foreach ($clientProfile in Get-VmsClientProfile) {
            $clientProfile | Set-VmsClientProfileAttributes -Namespace General -Attributes (@{ApplicationSnapshotPath = "C:\$($clientProfile.Name)"})
        }

        $path = Join-Path -Path ([io.path]::GetTempPath()) -ChildPath 'Import-VmsClientProfile2.json'
        try {
            $originalCount = (Get-VmsClientProfile -DefaultProfile:$false).Count
            Get-VmsClientProfile -DefaultProfile:$false | Export-VmsClientProfile -Path $path
            Get-VmsClientProfile -DefaultProfile:$false | Remove-VmsClientProfile -Confirm:$false
            (Get-VmsManagementServer).ClientProfileFolder.ClearChildrenCache()

            (Get-VmsClientProfile).Count | Should -Be 1

            $null = Import-VmsClientProfile -Path $path
            (Get-VmsClientProfile -DefaultProfile:$false).Count | Should -Be $originalCount
            (Get-VmsManagementServer).ClientProfileFolder.ClearChildrenCache()
            (Get-VmsClientProfile -DefaultProfile:$false).Count | Should -Be $originalCount
            foreach ($clientProfile in Get-VmsClientProfile) {
                ($clientProfile | Get-VmsClientProfileAttributes -Namespace General).ApplicationSnapshotPath.Value | Should -BeExactly "C:\$($clientProfile.Name)"
            }
        } finally {
            Remove-Item -Path $path
        }
    }
}
