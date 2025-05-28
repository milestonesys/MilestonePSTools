Context 'Add-VmsLoginProviderClaim' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        if ([version](Get-VmsManagementServer).Version -ge 22.1) {
            (Get-VmsManagementServer).LoginProviderFolder.ClearChildrenCache()
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
        }
    }

    It 'Can add registered claim to login provider' {
        if ([version](Get-VmsManagementServer).Version -lt 22.1) {
            $null | Should -BeNullOrEmpty -Because "External login providers are not supported until version 2022 R1. Current version is $((Get-VmsManagementServer).Version)."
            return
        }
        $provider = Get-VmsLoginProvider -Name 'Test' -ErrorAction Stop
        $provider | Add-VmsLoginProviderClaim -Name 'department', 'manager'
        $provider | Get-VmsLoginProviderClaim -Name department | Should -Not -BeNullOrEmpty
        $provider | Get-VmsLoginProviderClaim -Name manager | Should -Not -BeNullOrEmpty
    }
}
