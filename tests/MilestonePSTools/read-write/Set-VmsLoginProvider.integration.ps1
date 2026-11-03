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
            
            $updatedProvider.ClientSecretHasValue | Should -BeTrue
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

    It 'Can switch a login provider to certificate-based authentication and rotate the thumbprint' {
        if ([version](Get-VmsManagementServer).Version -lt 25.3) {
            $null | Should -BeNullOrEmpty -Because "Certificate-based external login providers are not supported until version 2025 R3. Current version is $((Get-VmsManagementServer).Version)."
            return
        }
        try {
            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
            $providerParams = @{
                Name          = 'Set-VmsLoginProvider.integration.ps1'
                ClientId      = '11111111-2222-3333-4444-555555555555'
                ClientSecret  = 'rLLKh428BmkKqr8G1rgoWZEDL7XKhgy9' | ConvertTo-SecureString -AsPlainText -Force
                Authority     = [uri]'https://login.microsoftonline.com/contoso.onmicrosoft.com/v2.0'
                UserNameClaim = 'preferred_username'
                Scopes        = 'email', 'profile'
                ErrorAction   = 'Stop'
            }
            $null = New-VmsLoginProvider @providerParams

            # Resolve the API Gateway once so we can read back clientSecretType, which
            # is not surfaced by the SDK LoginProvider object.
            $gatewayUri = (Get-RegisteredService -ServiceType 'e46b7bf9-03ce-44eb-bbdc-8ba16d0aaa80').UriArray | Select-Object -First 1
            $getSecretType = {
                param($Id)
                $uriBuilder = [uribuilder]$gatewayUri
                $uriBuilder.Path = $uriBuilder.Path.TrimEnd('/') + "/rest/v1/loginproviders/$Id"
                (Invoke-RestMethod -Uri $uriBuilder.Uri -Headers @{ Authorization = "Bearer $((Get-LoginSettings).IdentityTokenCache.Token)" }).data.clientSecretType
            }

            # Switch from shared secret to certificate-based authentication.
            $firstThumbprint = 'C263B6DC2B40237A9C13ED9FD84327033B6CD722'
            $provider = Get-VmsLoginProvider -Name $providerParams.Name -ErrorAction Stop
            $provider | Set-VmsLoginProvider -ClientSecret $firstThumbprint -ClientSecretType X509Thumbprint -ErrorAction Stop
            & $getSecretType $provider.Id | Should -BeExactly 'X509Thumbprint'

            # Rotate to a second thumbprint.
            $secondThumbprint = 'A1B2C3D4E5F60718293A4B5C6D7E8F9001122334'
            Get-VmsLoginProvider -Name $providerParams.Name | Set-VmsLoginProvider -ClientSecret $secondThumbprint -ClientSecretType X509Thumbprint -ErrorAction Stop
            & $getSecretType $provider.Id | Should -BeExactly 'X509Thumbprint'
        } finally {
            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
        }
    }
}
