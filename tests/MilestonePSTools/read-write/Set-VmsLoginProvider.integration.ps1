Context 'Set-VmsLoginProvider' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        if ([version](Get-VmsManagementServer).Version -ge 22.1) {
            (Get-VmsManagementServer).LoginProviderFolder.ClearChildrenCache()

            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
            $providerParams = @{
                Name          = 'Set-VmsLoginProvider.integration.ps1'
                ClientId      = 'qgrWLy9ho81mKErhK7ZD4k82rLXKLGgB'
                ClientSecret  = 'rLLKh428BmkKqr8G1rgoWZEDL7XKhgy9' | ConvertTo-SecureString -AsPlainText -Force
                Authority     = [uri]'https://www.milestonepstools.com/'
                UserNameClaim = 'email'
                Scopes        = 'email', 'profile'
                Verbose       = $true
                ErrorAction   = 'Stop'
            }
            $null = New-VmsLoginProvider @providerParams
        }
    }

    It 'Can update login provider settings' {
        if ([version](Get-VmsManagementServer).Version -lt 22.1) {
            $null | Should -BeNullOrEmpty -Because "External login providers are not supported until version 2022 R1. Current version is $((Get-VmsManagementServer).Version)."
            return
        }
        try {
            $provider = Get-VmsLoginProvider -Name 'Set-VmsLoginProvider.integration.ps1' -ErrorAction Stop
            $newParams = @{
                Name           = 'test-name'
                ClientId       = 'test-clientid'
                ClientSecret   = 'test-clientsecret'
                CallbackPath   = '/test-callbackpath/'
                Authority      = 'https://test.authority/'
                UserNameClaim  = 'test-usernameclaim'
                Scopes         = 'test-scope1', 'test-scope2'
                PromptForLogin = $false
                Enabled        = $true
                PassThru       = $true
            }
            $updatedProvider = $provider | Set-VmsLoginProvider @newParams
            Clear-VmsCache
            $updatedProvider = Get-VmsLoginProvider -Name $newParams.Name
            if ([version](Get-VmsManagementServer).Version -ge 23.1) {
                $updatedProvider.ClientSecretHasValue | Should -BeTrue
            } else {
                $updatedProvider.ClientSecret | Should -BeExactly $newParams.ClientSecret
            }
            $updatedProvider.PromptForLogin | Should -BeFalse
            $updatedProvider.UserNameClaimType | Should -BeExactly $newParams.UserNameClaim
            $newParams.Scopes | Foreach-Object {
                $updatedProvider.Scopes | Should -Contain $_
            }
            foreach ($key in $newParams.Keys | Where-Object { $_ -notin @('ClientSecret', 'Scopes', 'PassThru', 'UserNameClaim')}) {
                $updatedProvider.$key | Should -Be $newParams[$key]
            }
        } finally {
            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
        }
    }
}
