Context 'Remove-VmsClientProfile' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        (Get-VmsManagementServer).ClientProfileFolder.ClearChildrenCache()
        Get-VmsClientProfile -DefaultProfile:$false | Remove-VmsClientProfile
        1..4 | Foreach-Object {
            $null = New-VmsClientProfile -Name "Profile $_" -Description "Profile $_ description"
        }
    }

    It 'Can remove one client profile' {
        $clientProfile = Get-VmsClientProfile -DefaultProfile:$false | Select-Object -First 1
        $clientProfile | Remove-VmsClientProfile
        Get-VmsClientProfile -Name $clientProfile.Name -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        Clear-VmsCache
        Get-VmsClientProfile -Name $clientProfile.Name -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }

    It 'Can remove one client profile by name' {
        $clientProfile = Get-VmsClientProfile -DefaultProfile:$false | Select-Object -First 1
        Remove-VmsClientProfile -ClientProfile $clientProfile.Name
        Get-VmsClientProfile -Name $clientProfile.Name -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
        Clear-VmsCache
        Get-VmsClientProfile -Name $clientProfile.Name -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
    }

    It 'Does not remove profile with -WhatIf' {
        $clientProfile = Get-VmsClientProfile -DefaultProfile:$false | Select-Object -First 1
        Remove-VmsClientProfile -ClientProfile $clientProfile.Name -WhatIf
        Clear-VmsCache
        Get-VmsClientProfile -Name $clientProfile.Name -ErrorAction Stop | Should -Not -BeNullOrEmpty
    }

    It 'Can not remove default profile' {
        $defaultProfile = Get-VmsClientProfile -DefaultProfile
        $defaultProfile | Remove-VmsClientProfile -ErrorAction SilentlyContinue -ErrorVariable removeError
        $removeError | Should -Not -BeNullOrEmpty
        Clear-VmsCache
        Get-VmsClientProfile -Id $defaultProfile.Id | Should -Not -BeNullOrEmpty
        {
            $defaultProfile | Remove-VmsClientProfile -ErrorAction Stop
        } | Should -Throw
    }
}
