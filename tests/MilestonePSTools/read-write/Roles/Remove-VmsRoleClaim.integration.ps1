Context 'Remove-VmsRoleClaim' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        if ([version](Get-VmsManagementServer).Version -ge 22.1) {
            (Get-VmsManagementServer).LoginProviderFolder.ClearChildrenCache()
        }
    }

    It 'Can remove claim from role by name' {
        if ([version](Get-VmsManagementServer).Version -lt 22.1) {
            $null | Should -BeNullOrEmpty -Because "External login providers are not supported until version 2022 R1. Current version is $((Get-VmsManagementServer).Version)."
            return
        }

        Clear-VmsCache
        Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
        Get-VmsRole -Name 'Remove-VmsRoleClaim.integration.ps1' -ErrorAction SilentlyContinue | Remove-VmsRole -Confirm:$false

        try {
            $providerParams = @{
                Name          = 'Remove-VmsRoleClaim.integration.ps1'
                ClientId      = 'qgrWLy9ho81mKErhK7ZD4k82rLXKLGgB'
                ClientSecret  = 'rLLKh428BmkKqr8G1rgoWZEDL7XKhgy9' | ConvertTo-SecureString -AsPlainText -Force
                Authority     = [uri]'https://www.milestonepstools.com/'
                UserNameClaim = 'email'
                Scopes        = 'email', 'profile'
                Verbose       = $true
                ErrorAction   = 'Stop'
            }

            $provider = New-VmsLoginProvider @providerParams
            $provider | Add-VmsLoginProviderClaim -Name groups
            $role = New-VmsRole -Name $providerParams.Name -PassThru
            $role | Add-VmsRoleClaim -LoginProvider $provider -ClaimName groups -ClaimValue test
            $role.ClaimFolder.ClearChildrenCache()
            ($role | Get-VmsRoleClaim -ClaimName 'groups').ClaimName | Should -BeExactly 'groups'
            Get-VmsRole -Name $providerParams.Name | Remove-VmsRoleClaim -ClaimName 'groups'
            Clear-VmsCache
            {
                Get-VmsRole -Name $providerParams.Name | Get-VmsRoleClaim -ClaimName 'groups' -ErrorAction Stop
            } | Should -Throw
        } finally {
            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
            Get-VmsRole -Name 'Remove-VmsRoleClaim.integration.ps1' -ErrorAction SilentlyContinue | Remove-VmsRole -Confirm:$false
        }
    }

    It 'Can remove claim from role by name and value' {
        if ([version](Get-VmsManagementServer).Version -lt 22.1) {
            $null | Should -BeNullOrEmpty -Because "External login providers are not supported until version 2022 R1. Current version is $((Get-VmsManagementServer).Version)."
            return
        }

        Clear-VmsCache
        Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
        Get-VmsRole -Name 'Remove-VmsRoleClaim.integration.ps1' -ErrorAction SilentlyContinue | Remove-VmsRole -Confirm:$false

        try {
            $providerParams = @{
                Name          = 'Remove-VmsRoleClaim.integration.ps1'
                ClientId      = 'qgrWLy9ho81mKErhK7ZD4k82rLXKLGgB'
                ClientSecret  = 'rLLKh428BmkKqr8G1rgoWZEDL7XKhgy9' | ConvertTo-SecureString -AsPlainText -Force
                Authority     = [uri]'https://www.milestonepstools.com/'
                UserNameClaim = 'email'
                Scopes        = 'email', 'profile'
                Verbose       = $true
                ErrorAction   = 'Stop'
            }

            $provider = New-VmsLoginProvider @providerParams
            $provider | Add-VmsLoginProviderClaim -Name groups
            $role = New-VmsRole -Name $providerParams.Name -PassThru
            $role | Add-VmsRoleClaim -LoginProvider $provider -ClaimName groups -ClaimValue test
            $role.ClaimFolder.ClearChildrenCache()
            ($role | Get-VmsRoleClaim -ClaimName 'groups').ClaimName | Should -BeExactly 'groups'
            Get-VmsRole -Name $providerParams.Name | Remove-VmsRoleClaim -ClaimName 'groups' -ClaimValue test
            Clear-VmsCache
            Get-VmsRole -Name $providerParams.Name | Get-VmsRoleClaim -ClaimName 'groups' -ErrorAction SilentlyContinue | Where-Object ClaimValue -eq 'test' | Should -BeNullOrEmpty
        } finally {
            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
            Get-VmsRole -Name 'Remove-VmsRoleClaim.integration.ps1' -ErrorAction SilentlyContinue | Remove-VmsRole -Confirm:$false
        }
    }

    It 'Can remove claim from role by name, value, and login provider' {
        if ([version](Get-VmsManagementServer).Version -lt 22.1) {
            $null | Should -BeNullOrEmpty -Because "External login providers are not supported until version 2022 R1. Current version is $((Get-VmsManagementServer).Version)."
            return
        }

        Clear-VmsCache
        Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
        Get-VmsRole -Name 'Remove-VmsRoleClaim.integration.ps1' -ErrorAction SilentlyContinue | Remove-VmsRole -Confirm:$false

        try {
            $providerParams = @{
                Name          = 'Remove-VmsRoleClaim.integration.ps1'
                ClientId      = 'qgrWLy9ho81mKErhK7ZD4k82rLXKLGgB'
                ClientSecret  = 'rLLKh428BmkKqr8G1rgoWZEDL7XKhgy9' | ConvertTo-SecureString -AsPlainText -Force
                Authority     = [uri]'https://www.milestonepstools.com/'
                UserNameClaim = 'email'
                Scopes        = 'email', 'profile'
                Verbose       = $true
                ErrorAction   = 'Stop'
            }

            $provider = New-VmsLoginProvider @providerParams
            $provider | Add-VmsLoginProviderClaim -Name groups
            $role = New-VmsRole -Name $providerParams.Name -PassThru
            $role | Add-VmsRoleClaim -LoginProvider $provider -ClaimName groups -ClaimValue test
            $role.ClaimFolder.ClearChildrenCache()
            ($role | Get-VmsRoleClaim -ClaimName 'groups').ClaimName | Should -BeExactly 'groups'
            Get-VmsRole -Name $providerParams.Name | Remove-VmsRoleClaim -ClaimName 'groups' -ClaimValue test -LoginProvider $provider.Name
            Clear-VmsCache
            Get-VmsRole -Name $providerParams.Name | Get-VmsRoleClaim -ClaimName 'groups' -ErrorAction SilentlyContinue | Where-Object { $_.ClaimValue -eq 'test' -and $_.ClaimProvider -eq $provider.Id } | Should -BeNullOrEmpty
        } finally {
            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
            Get-VmsRole -Name 'Remove-VmsRoleClaim.integration.ps1' -ErrorAction SilentlyContinue | Remove-VmsRole -Confirm:$false
        }
    }
}
