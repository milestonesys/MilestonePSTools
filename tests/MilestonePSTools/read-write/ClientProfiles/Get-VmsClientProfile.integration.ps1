Context 'Get-VmsClientProfile' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        (Get-VmsManagementServer).ClientProfileFolder.ClearChildrenCache()
        Get-VmsClientProfile -DefaultProfile:$false | Remove-VmsClientProfile
    }

    It 'Can get default client profile' {
        $clientProfile = Get-VmsClientProfile -DefaultProfile
        $clientProfile.Count | Should -Be 1
        $clientProfile.IsDefaultProfile | Should -BeTrue
    }

    It 'Can get client profile by Name' {
        $name = (Get-VmsClientProfile -DefaultProfile).Name
        $clientProfile = Get-VmsClientProfile -Name $name
        $clientProfile.Count | Should -Be 1
        $clientProfile.Name | Should -BeExactly $name
    }

    It 'Can get client profile by Id' {
        $id = (Get-VmsClientProfile -DefaultProfile).Id
        $clientProfile = Get-VmsClientProfile -Id $id
        $clientProfile.Count | Should -Be 1
        $clientProfile.Id | Should -Be $id
    }

    It 'Can get all client profiles' {
        $newProfiles = 1..5 | Foreach-Object {
            New-VmsClientProfile -Name "Get-VmsClientProfile $_"
        }
        (Get-VmsClientProfile).Count | Should -BeGreaterOrEqual $newProfiles.Count
        $newProfiles | Remove-VmsClientProfile
    }
}
