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

    It 'Can add a certificate-based login provider' {
        if ([version](Get-VmsManagementServer).Version -lt 25.3) {
            $null | Should -BeNullOrEmpty -Because "Certificate-based external login providers are not supported until version 2025 R3. Current version is $((Get-VmsManagementServer).Version)."
            return
        }

        if (Get-VmsLoginProvider) {
            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
        }
        $thumbprint = 'C263B6DC2B40237A9C13ED9FD84327033B6CD722'
        $providerParams = @{
            Name             = 'EntraID'
            ClientId         = '11111111-2222-3333-4444-555555555555'
            ClientSecret     = $thumbprint | ConvertTo-SecureString -AsPlainText -Force
            ClientSecretType = 'X509Thumbprint'
            Authority        = [uri]'https://login.microsoftonline.com/contoso.onmicrosoft.com/v2.0'
            UserNameClaim    = 'preferred_username'
            Scopes           = 'email', 'profile'
            Verbose          = $true
            ErrorAction      = 'Stop'
        }
        $loginProvider = New-VmsLoginProvider @providerParams
        $loginProvider | Should -Not -BeNullOrEmpty
        $loginProvider.ClientId | Should -BeExactly $providerParams.ClientId

        # The SDK LoginProvider object does not surface clientSecretType, so read it
        # back directly from the API Gateway to confirm certificate-based auth was set.
        $gatewayUri = (Get-RegisteredService -ServiceType 'e46b7bf9-03ce-44eb-bbdc-8ba16d0aaa80').UriArray | Select-Object -First 1
        $uriBuilder = [uribuilder]$gatewayUri
        $uriBuilder.Path = $uriBuilder.Path.TrimEnd('/') + "/rest/v1/loginproviders/$($loginProvider.Id)"
        $response = Invoke-RestMethod -Uri $uriBuilder.Uri -Headers @{ Authorization = "Bearer $((Get-LoginSettings).IdentityTokenCache.Token)" }
        $response.data.clientSecretType | Should -BeExactly 'X509Thumbprint'
    }
}
