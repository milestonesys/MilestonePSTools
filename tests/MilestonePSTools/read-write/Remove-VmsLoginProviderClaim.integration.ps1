Context 'Remove-VmsLoginProviderClaim' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        if ([version](Get-VmsManagementServer).Version -ge 22.1) {
            (Get-VmsManagementServer).LoginProviderFolder.ClearChildrenCache()
            if (Get-VmsLoginProvider) {
                Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
            }

            $providerParams = @{
                Name          = 'Remove-VmsLoginProviderClaim.integration.ps1'
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

    It 'Can remove named login provider claim' {
        if ([version](Get-VmsManagementServer).Version -lt 22.1) {
            $null | Should -BeNullOrEmpty -Because "External login providers are not supported until version 2022 R1. Current version is $((Get-VmsManagementServer).Version)."
            return
        }

        $provider = Get-VmsLoginProvider -Name 'Remove-VmsLoginProviderClaim.integration.ps1' -ErrorAction Stop
        $provider | Remove-VmsLoginProviderClaim -All -Confirm:$false
        $provider | Add-VmsLoginProviderClaim -Name 'claim1', 'claim2', 'claim3' -ErrorAction Stop
        $claims = $provider | Get-VmsLoginProviderClaim
        $claims.Count | Should -Be 3

        $provider | Remove-VmsLoginProviderClaim -ClaimName 'claim1' -Force -Confirm:$false
        Clear-VmsCache
        $provider = Get-VmsLoginProvider -Name 'Remove-VmsLoginProviderClaim.integration.ps1' -ErrorAction Stop
        ($provider | Get-VmsLoginProviderClaim).Name | Should -Not -Contain 'claim1'
    }

    It 'Can remove all login provider claims' {
        if ([version](Get-VmsManagementServer).Version -lt 22.1) {
            $null | Should -BeNullOrEmpty -Because "External login providers are not supported until version 2022 R1. Current version is $((Get-VmsManagementServer).Version)."
            return
        }

        $provider = Get-VmsLoginProvider -Name 'Remove-VmsLoginProviderClaim.integration.ps1' -ErrorAction Stop
        $provider | Remove-VmsLoginProviderClaim -All -Confirm:$false
        $provider | Add-VmsLoginProviderClaim -Name 'claim1', 'claim2', 'claim3' -ErrorAction Stop
        $claims = $provider | Get-VmsLoginProviderClaim
        $claims.Count | Should -Be 3

        $provider | Remove-VmsLoginProviderClaim -All -Force -Confirm:$false
        Clear-VmsCache
        $provider = Get-VmsLoginProvider -Name 'Remove-VmsLoginProviderClaim.integration.ps1' -ErrorAction Stop
        $provider | Get-VmsLoginProviderClaim | Should -BeNullOrEmpty
    }
}
