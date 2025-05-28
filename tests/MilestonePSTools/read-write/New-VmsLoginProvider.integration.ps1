Context 'New-VmsLoginProvider' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        if ([version](Get-VmsManagementServer).Version -ge 22.1) {
            (Get-VmsManagementServer).LoginProviderFolder.ClearChildrenCache()
        }
    }

    It 'Can add login provider' {
        if ([version](Get-VmsManagementServer).Version -lt 22.1) {
            $null | Should -BeNullOrEmpty -Because "External login providers are not supported until version 2022 R1. Current version is $((Get-VmsManagementServer).Version)."
            return
        }

        if (Get-VmsLoginProvider) {
            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
        }
        $providerParams = @{
            Name          = 'Auth0'
            ClientId      = 'qgrWLy9ho81mKErhK7ZD4k82rLXKLGgB'
            ClientSecret  = 'M_4P4IZQo0X4oxPwrrxWkh8y8Hjas9yl8VOFM6DQR4jlvMdJB3S0oL768b25MtIA' | ConvertTo-SecureString -AsPlainText -Force
            Authority     = [uri]'https://dev-hYz2AYg0WmmTSE4C.us.auth0.com/'
            UserNameClaim = 'email'
            Scopes        = 'email', 'profile'
            Verbose       = $true
            ErrorAction   = 'Stop'
        }
        $loginProvider = New-VmsLoginProvider @providerParams
        $loginProvider | Should -Not -BeNullOrEmpty
        $loginProvider.ClientId | Should -BeExactly $providerParams.ClientId
        [uri]$loginProvider.Authority | Should -BeExactly $providerParams.Authority
        $loginProvider.UserNameClaimType | Should -BeExactly $providerParams.UserNameClaim
        $loginProvider.Scopes.Count | Should -BeExactly $providerParams.Scopes.Count
    }
}
