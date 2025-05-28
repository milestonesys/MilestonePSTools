Context 'Set-VmsClientProfile' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        (Get-VmsManagementServer).ClientProfileFolder.ClearChildrenCache()
        Get-VmsClientProfile -DefaultProfile:$false | Remove-VmsClientProfile
        1..4 | Foreach-Object {
            $null = New-VmsClientProfile -Name "Profile $_" -Description "Profile $_ description"
        }
    }

    It 'Can update client profile name and description' {
        $clientProfile = Get-VmsClientProfile -DefaultProfile:$false | Get-Random
        $setParams = @{
            Name        = (New-Guid).ToString()
            Description = (New-Guid).ToString()
        }
        $updatedProfile = $clientProfile | Set-VmsClientProfile @setParams -PassThru
        $updatedProfile.Name | Should -BeExactly $setParams.Name
        $updatedProfile.Description | Should -BeExactly $setParams.Description
        Clear-VmsCache
        $updatedProfile = Get-VmsClientProfile -Id $updatedProfile.Id
        $updatedProfile.Name | Should -BeExactly $setParams.Name
        $updatedProfile.Description | Should -BeExactly $setParams.Description
    }

    It 'Can change client profile priority' {
        $clientProfile = (Get-VmsClientProfile)[-2]

        $clientProfile | Set-VmsClientProfile -Priority 1
        (Get-VmsClientProfile)[0].Id | Should -BeExactly $clientProfile.Id

        $clientProfile | Set-VmsClientProfile -Priority 2
        (Get-VmsClientProfile)[1].Id | Should -BeExactly $clientProfile.Id

        $clientProfile | Set-VmsClientProfile -Priority ([int]::MaxValue)
        (Get-VmsClientProfile)[-2].Id | Should -BeExactly $clientProfile.Id
    }
}
