Context 'New-VmsClientProfile' -Skip:($script:SkipReadWriteTests) {
    It 'Can create new client profile' {
        $profileParams = @{
            Name        = (New-Guid).ToString()
            Description = (New-Guid).ToString()
        }
        $newProfile = New-VmsClientProfile @profileParams
        $newProfile.Name | Should -BeExactly $profileParams.Name
        $newProfile.Description | Should -BeExactly $profileParams.Description
    }

    It 'A non-terminating error is thrown if the profile already exists' {
        $existingProfile = Get-VmsClientProfile | Select-Object -First 1
        $null = New-VmsClientProfile -Name $existingProfile.Name -ErrorAction SilentlyContinue -ErrorVariable profileError
        $profileError | Should -Not -BeNullOrEmpty
        {
            $null = New-VmsClientProfile -Name $existingProfile.Name -ErrorAction Stop
        } | Should -Throw
    }
}
