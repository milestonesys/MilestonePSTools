Context 'Get-VmsLoginProvider' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        if ([version](Get-VmsManagementServer).Version -ge 22.1) {
            (Get-VmsManagementServer).LoginProviderFolder.ClearChildrenCache()
        }
    }

    Context 'Parameterless' {
        It 'Returns null when no provider exists' {
            if ([version](Get-VmsManagementServer).Version -lt 22.1) {
                $null | Should -BeNullOrEmpty -Because "External login providers are not supported until version 2022 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }

            if (Get-VmsLoginProvider) {
                Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
            }
            Get-VmsLoginProvider | Should -BeNullOrEmpty
        }

        It 'Returns all existing providers' {
            if (Get-VmsLoginProvider) {
                Write-Verbose "Removing existing login provider '$((Get-VmsLoginProvider).Name)'"
                Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false -ErrorAction Stop
            }
            $providerParams = @{
                Name          = 'Test'
                ClientId      = 'qgrWLy9ho81mKErhK7ZD4k82rLXKLGgB'
                ClientSecret  = 'rLLKh428BmkKqr8G1rgoWZEDL7XKhgy9' | ConvertTo-SecureString -AsPlainText -Force
                Authority     = [uri]'https://www.milestonepstools.com/'
                UserNameClaim = 'email'
                Scopes        = 'email', 'profile'
                Verbose       = $true
                ErrorAction   = 'Stop'
            }
            Write-Verbose "Creating login provider $($providerParams.Name)"
            $null = New-VmsLoginProvider @providerParams

            (Get-VmsLoginProvider).Count | Should -BeExactly 1
        }
    }

    Context 'Named' {
        It 'Returns named provider' {
            if (Get-VmsLoginProvider) {
                Write-Verbose "Removing existing login provider '$((Get-VmsLoginProvider).Name)'"
                Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false -ErrorAction Stop
            }
            $providerParams = @{
                Name          = 'Test-{0}' -f (Get-Random -Minimum 1 -Maximum 99999)
                ClientId      = 'qgrWLy9ho81mKErhK7ZD4k82rLXKLGgB'
                ClientSecret  = 'rLLKh428BmkKqr8G1rgoWZEDL7XKhgy9' | ConvertTo-SecureString -AsPlainText -Force
                Authority     = [uri]'https://www.milestonepstools.com/'
                UserNameClaim = 'email'
                Scopes        = 'email', 'profile'
                Verbose       = $true
                ErrorAction   = 'Stop'
            }
            Write-Verbose "Creating login provider $($providerParams.Name)"
            $null = New-VmsLoginProvider @providerParams

            (Get-VmsLoginProvider -Name $providerParams.Name).Count | Should -BeExactly 1
            (Get-VmsLoginProvider -Name $providerParams.Name).Name | Should -BeExactly -ExpectedValue $providerParams.Name
        }

        It 'Returns an error if provider name not found' {
            { Get-VmsLoginProvider -Name (New-Guid) -ErrorAction Stop } | Should -Throw
        }
    }
}
