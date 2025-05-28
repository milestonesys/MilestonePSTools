Context 'Get-VmsRoleClaim' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        if ([version](Get-VmsManagementServer).Version -ge 22.1) {
            (Get-VmsManagementServer).LoginProviderFolder.ClearChildrenCache()
        }
    }

    It 'Can get claims from role' {
        if ([version](Get-VmsManagementServer).Version -lt 22.1) {
            $null | Should -BeNullOrEmpty -Because "External login providers are not supported until version 2022 R1. Current version is $((Get-VmsManagementServer).Version)."
            return
        }

        Clear-VmsCache
        if (Get-VmsLoginProvider) {
            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
        }
        if (($role = Get-VmsRole -Name 'Get-VmsRoleClaim.integration.ps1' -ErrorAction SilentlyContinue)) {
            $role | Remove-VmsRole -Confirm:$false
        }

        try {
            $providerParams = @{
                Name          = 'Get-VmsRoleClaim.integration.ps1'
                ClientId      = 'qgrWLy9ho81mKErhK7ZD4k82rLXKLGgB'
                ClientSecret  = 'rLLKh428BmkKqr8G1rgoWZEDL7XKhgy9' | ConvertTo-SecureString -AsPlainText -Force
                Authority     = [uri]'https://www.milestonepstools.com/'
                UserNameClaim = 'email'
                Scopes        = 'email', 'profile'
                Verbose       = $true
                ErrorAction   = 'Stop'
            }

            $provider = New-VmsLoginProvider @providerParams
            $provider | Add-VmsLoginProviderClaim -Name groups, email
            $role = New-VmsRole -Name $providerParams.Name -PassThru
            $role | Add-VmsRoleClaim -LoginProvider $provider -ClaimName groups -CLaimValue 'test'
            Clear-VmsCache
            (Get-VmsRole -Name $providerParams.Name | Get-VmsRoleClaim -LoginProvider $provider -ClaimName 'groups').ClaimValue | Should -BeExactly 'test'
        } finally {
            if (Get-VmsLoginProvider) {
                Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
            }
            if (($role = Get-VmsRole -Name 'Get-VmsRoleClaim.integration.ps1' -ErrorAction SilentlyContinue)) {
                $role | Remove-VmsRole -Confirm:$false
            }
        }
    }
}
