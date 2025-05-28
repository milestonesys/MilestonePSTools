Context 'Remove-VmsLoginProvider' -Skip:($script:SkipReadWriteTests)  {
    BeforeAll {
        if ([version](Get-VmsManagementServer).Version -ge 22.1) {
            (Get-VmsManagementServer).LoginProviderFolder.ClearChildrenCache()
        }
    }

    It 'Can remove login provider' {
        if ([version](Get-VmsManagementServer).Version -lt 22.1) {
            $null | Should -BeNullOrEmpty -Because "External login providers are not supported until version 2022 R1. Current version is $((Get-VmsManagementServer).Version)."
            return
        }

        if (Get-VmsLoginProvider) {
            Get-VmsLoginProvider | Remove-VmsLoginProvider -Force -Confirm:$false
        }

        $providerParams = @{
            Name          = 'Remove-VmsLoginProvider.integration.ps1'
            ClientId      = 'qgrWLy9ho81mKErhK7ZD4k82rLXKLGgB'
            ClientSecret  = 'rLLKh428BmkKqr8G1rgoWZEDL7XKhgy9' | ConvertTo-SecureString -AsPlainText -Force
            Authority     = [uri]'https://www.milestonepstools.com/'
            UserNameClaim = 'email'
            Scopes        = 'email', 'profile'
            Verbose       = $true
            ErrorAction   = 'Stop'
        }
        $null = New-VmsLoginProvider @providerParams
        $loginProvider = Get-VmsLoginProvider -Name $providerParams.Name
        { $loginProvider | Remove-VmsLoginProvider -Force -Confirm:$false -ErrorAction Stop } | Should -Not -Throw
        { Get-VmsLoginProvider -Name $providerParams.Name } | Should -Throw
        $loginProvider = Get-VmsLoginProvider | Where-Object Name -eq $providerParams.Name
        $loginProvider | Should -BeNullOrEmpty
    }
}
