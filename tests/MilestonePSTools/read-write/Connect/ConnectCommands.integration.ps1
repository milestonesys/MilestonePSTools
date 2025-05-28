Context 'Connect Commands' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        Save-VmsConnectionProfile -Name 'default' -Force
        Save-VmsConnectionProfile -Name 'custom' -Force
        $script:connectionProfile = Get-VmsConnectionProfile
    }

    Describe 'Disconnect-Vms' {
        It 'Can logout' {
            Test-VmsConnection | Should -BeTrue
            Disconnect-Vms
            Test-VmsConnection | Should -BeFalse
        }

        It 'Can be called when disconnected' {
            {
                try {
                    Disconnect-Vms -ErrorAction Stop
                    Disconnect-Vms -ErrorAction Stop
                } catch {
                    throw
                }
                
            } | Should -Not -Throw
        }
    }

    Describe 'Connect-Vms' {
        It 'Connects using named profile: <name>' -TestCases @(
            @{ Name = 'default' },
            @{ Name = 'custom' }
        ) {
            Disconnect-Vms
            $null = Connect-Vms -Name $name
            Test-VmsConnection | Should -BeTrue
        }

        It 'Connects using ServerAddress parameter set' {
            Disconnect-Vms
            $splat = @{
                ServerAddress     = $script:connectionProfile.ServerAddress
                SecureOnly        = $script:connectionProfile.SecureOnly
                IncludeChildSites = $script:connectionProfile.IncludeChildSites
                AcceptEula        = $true
            }
            if ($script:connectionProfile.Credential) {
                $splat.Credential = $script:connectionProfile.Credential
                $splat.BasicUser  = $script:connectionProfile.BasicUser
            }
            Connect-Vms @splat -ErrorAction Stop
            Test-VmsConnection | Should -BeTrue
        }

        It 'Connects using ServerAddress parameter set with values from pipeline' {
            Disconnect-Vms
            $script:connectionProfile | Connect-Vms -ErrorAction Stop
            Test-VmsConnection | Should -BeTrue
        }

        It 'Can connect without saving profile to disk' {
            Disconnect-Vms
            Remove-VmsConnectionProfile -All
            (Get-VmsConnectionProfile -All).Count | Should -Be 0

            $script:connectionProfile | Select-Object * -ExcludeProperty Name | Connect-Vms -ErrorAction Stop
            Test-VmsConnection | Should -BeTrue
            (Get-VmsConnectionProfile -All).Count | Should -Be 0
        }
    }
}
