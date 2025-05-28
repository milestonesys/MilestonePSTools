Context 'Copy-VmsClientProfile' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        (Get-VmsManagementServer).ClientProfileFolder.ClearChildrenCache()
        Get-VmsClientProfile -DefaultProfile:$false | Remove-VmsClientProfile
    }

    It 'Can copy default client profile' {
        $original = Get-VmsClientProfile -DefaultProfile
        $copy = $original | Copy-VmsClientProfile -NewName "Copy-VmsClientProfile.Can copy default client profile"
        $originalAttributes = $original | Get-VmsClientProfileAttributes | ConvertTo-Json -Compress
        $copyAttributes = $copy | Get-VmsClientProfileAttributes | ConvertTo-Json -Compress
        $copyAttributes | Should -BeExactly $originalAttributes
        if ($copy) {
            $copy | Remove-VmsClientProfile
        }
    }

    It 'Can copy non-default client profile' {
        $original = New-VmsClientProfile -Name "Copy-VmsClientProfile.Can copy non-default client profile" -Description "Copy-VmsClientProfile.Can copy non-default client profile"
        $general = $original | Get-VmsClientProfileAttributes -Namespace General
        $general.ApplicationAutoLogin.Value = if ($general.ApplicationAutoLogin.Value -eq 'Available') {'Unavailable'} else {'Available'}
        $original = $original | Set-VmsClientProfileAttributes -Attributes $general
        $copy = $original | Copy-VmsClientProfile -NewName  "Copy-VmsClientProfile.Can copy non-default client profile Copy"
        $originalAttributes = $original | Get-VmsClientProfileAttributes | ConvertTo-Json -Compress
        $copyAttributes = $copy | Get-VmsClientProfileAttributes | ConvertTo-Json -Compress
        $copyAttributes | Should -BeExactly $originalAttributes
        $original | Remove-VmsClientProfile
        $copy | Remove-VmsClientProfile
    }
}
