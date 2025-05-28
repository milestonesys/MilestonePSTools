Context 'Set-VmsLoginProviderClaim' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        if ([version](Get-VmsManagementServer).Version -ge 22.1) {
            (Get-VmsManagementServer).LoginProviderFolder.ClearChildrenCache()

            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
            $providerParams = @{
                Name          = 'Set-VmsLoginProviderClaim.integration.ps1'
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

    It 'Can update registered claims' {
        if ([version](Get-VmsManagementServer).Version -lt 22.1) {
            $null | Should -BeNullOrEmpty -Because "External login providers are not supported until version 2022 R1. Current version is $((Get-VmsManagementServer).Version)."
            return
        }
        try {
            $provider = Get-VmsLoginProvider -Name 'Set-VmsLoginProviderClaim.integration.ps1' -ErrorAction Stop
            $provider | Add-VmsLoginProviderClaim -Name 'groups' -DisplayName 'Security Groups'
            $provider | Get-VmsLoginProviderClaim -Name 'groups'| Set-VmsLoginProviderClaim -Name 'roles' -DisplayName 'Security Roles'
            Clear-VmsCache
            $claim = Get-VmsLoginProvider -Name $provider.Name | Get-VmsLoginProviderClaim -Name 'roles'
            $claim.Name | Should -BeExactly 'roles'
            $claim.DisplayName | Should -BeExactly 'Security Roles'
        } finally {
            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
        }
    }
}
