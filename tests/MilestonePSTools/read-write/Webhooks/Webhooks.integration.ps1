Context 'Webhooks' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        if ([version](Get-VmsManagementServer).Version -ge 23.1) {
            Get-VmsWebhook | Remove-VmsWebhook -Confirm:$false
        }
    }

    Describe 'New-VmsWebhook' {
        It 'Can create <name>' -ForEach @(
            @{ Name = 'webhook with HTTP scheme'; Address = 'http://localhost/http-scheme' },
            @{ Name = 'webhook with HTTPS scheme'; Address = 'https://localhost/https-scheme' },
            @{ Name = 'duplicate webhook name'; Address = 'http://localhost/duplicate' },
            @{ Name = 'duplicate webhook name'; Address = 'http://localhost/duplicate' },
            @{ Name = 'webhook with special characters !@#$%^&*()_+-={}[]\{}|;'':",./<>?'; Address = 'http://localhost/special-characters' }
        ) {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            $webhook = New-VmsWebhook -Name $name -Address $address
            $webhook | Should -BeOfType -ExpectedType ([MilestonePSTools.Webhook])
            $webhook.Name | Should -BeExactly $name
            $webhook.Address | Should -BeExactly $address
        }

        It 'Can create <name>' -ForEach @(
            @{ Name = 'webhook with simple token'; Address = 'http://localhost/simple-token'; Token = 'simple-token' },
            @{ Name = 'webhook with empty token'; Address = 'http://localhost/empty-token'; Token = '' },
            @{ Name = 'webhook with null token'; Address = 'http://localhost/null-token'; Token = $null },
            @{ Name = 'webhook with extended characters in token'; Address = 'http://localhost/extended-chars'; Token = '私はPowerShellが大好きです' }
        ) {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            $webhook = New-VmsWebhook -Name $name -Address $address -Token $token
            $webhook | Should -BeOfType -ExpectedType ([MilestonePSTools.Webhook])
            $webhook.Name | Should -BeExactly $name
            $webhook.Address | Should -BeExactly $address
            if ($null -eq $token) {
                $webhook.Token | Should -BeExactly ([string]::Empty)
            } else {
                $webhook.Token | Should -BeExactly $token
            }
            
        }

        It 'Can create <name>' -ForEach @(
            @{ Name = 'webhook from pipeline with token value'; Address = 'http://localhost/pipeline'; Token = 'simple-token' },
            @{ Name = 'webhook from pipeline with empty token'; Address = 'http://localhost/pipeline'; Token = '' },
            @{ Name = 'webhook from pipeline with null token'; Address = 'http://localhost/pipeline'; Token = $null }
        ) {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            $obj = @{
                Name    = $name
                Address = $address
            }
            if ($token) {
                $obj.Token = $token
            }
            $webhook = [pscustomobject]$obj | New-VmsWebhook
            $webhook | Should -BeOfType -ExpectedType ([MilestonePSTools.Webhook])
            $webhook.Name | Should -BeExactly $name
            $webhook.Address | Should -BeExactly $address
            if ($null -eq $token) {
                $webhook.Token | Should -BeExactly ([string]::Empty)
            } else {
                $webhook.Token | Should -BeExactly $token
            }
        }
    }

    Describe 'Get-VmsWebhook' {
        It 'Can get all webhooks' {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            (Get-VmsWebhook).Count | Should -BeGreaterThan 0
        }

        It 'Can get webhook by name' {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            $name = (New-Guid).ToString()
            $null = New-VmsWebhook -Name $name -Address 'http://localhost'
            $webhook = Get-VmsWebhook -Name $name
            $webhook.Name | Should -BeExactly $name
        }

        It 'Can get webhook by literal name' {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            $name = (New-Guid).ToString()
            $null = New-VmsWebhook -Name $name -Address 'http://localhost'
            $webhook = Get-VmsWebhook -LiteralName $name
            $webhook.Name | Should -BeExactly $name
        }

        It 'Can get webhook with wildcard' {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            $name = 'Wildcard Test {0}' -f (New-Guid)
            $null = New-VmsWebhook -Name $name -Address 'http://localhost'
            $webhook = Get-VmsWebhook -Name 'Wildcard Test*'
            $webhook.Name | Should -BeExactly $name
        }
    }

    Describe 'Set-VmsWebhook' {
        It 'Can update all properties by name' {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            $webhook = Get-VmsWebhook | Select-Object -First 1
            $newName = "Renamed Webhook $(New-Guid)"
            $newAddress = "http://localhost/$(New-Guid)"
            $newToken = New-Guid
            $webhook = $webhook | Set-VmsWebhook -NewName $newName -Address $newAddress -Token $newToken -PassThru
            $webhook.Name | Should -BeExactly $newName
            $webhook.Address | Should -BeExactly $newAddress
            $webhook.Token | Should -BeExactly $newToken
        }

        It 'Can update all properties from pipeline' {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            $webhook = Get-VmsWebhook | Select-Object -First 1 -Property *
            $webhook | Add-Member -MemberType NoteProperty -Name 'NewName' -Value "Renamed Webhook $(New-Guid)"
            $webhook.Address = "http://localhost/$(New-Guid)"
            $webhook.Token = New-Guid
            $updatedWebhook = $webhook | Set-VmsWebhook -PassThru
            $updatedWebhook.Name | Should -BeExactly $webhook.NewName
            $updatedWebhook.Address | Should -BeExactly $webhook.Address
            $updatedWebhook.Token | Should -BeExactly $webhook.Token
        }

        It 'Can accept null and empty token values' {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            
            $webhook = New-VmsWebhook -Name (New-Guid) -Address 'http://localhost' -Token 'secret'
            $webhook = $webhook | Set-VmsWebhook -Token $null -PassThru
            $webhook.Token | Should -BeExactly ([string]::Empty)
            
            $webhook = New-VmsWebhook -Name (New-Guid) -Address 'http://localhost' -Token 'secret'
            $webhook = $webhook | Set-VmsWebhook -Token '' -PassThru
            $webhook.Token | Should -BeExactly ([string]::Empty)
        }
    }

    Describe 'Remove-VmsWebhook' {
        BeforeAll {
            if ([version](Get-VmsManagementServer).Version -ge 23.1) {
                Get-VmsWebhook | Remove-VmsWebhook -ErrorAction Stop
                $script:stack = [collections.generic.stack[MilestonePSTools.Webhook]]::New()
                1..10 | ForEach-Object {
                    $script:stack.Push((New-VmsWebhook -Name "Webhook $_" -Address "http://localhost/webhook/$_"))
                }
                1..2 | ForEach-Object {
                    $null = New-VmsWebhook -Name 'Duplicate Webhook Name' -Address 'http://localhost/duplicate'
                }
            }
        }

        It 'Can remove token by unique name' {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            $webhook = $script:stack.Pop()
            {
                Remove-VmsWebhook -Name $webhook.Name -ErrorAction Stop
            } | Should -Not -Throw
            {
                Get-VmsWebhook -Name $webhook.Name -ErrorAction Stop
            } | Should -Throw
        }

        It 'Can remove token by path' {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            $webhook = $script:stack.Pop()
            {
                Remove-VmsWebhook -Path $webhook.Path -ErrorAction Stop
            } | Should -Not -Throw
            {
                Get-VmsWebhook -Path $webhook.Path -ErrorAction Stop
            } | Should -Throw
        }

        It 'Cannot remove token with duplicate name' {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            $webhook = Get-VmsWebhook -Name 'Duplicate Webhook Name' -ErrorAction Stop
            {
                Remove-VmsWebhook -Name $webhook.Name -ErrorAction Stop
            } | Should -Throw
        }

        It 'Can remove all webhooks' {
            if ([version](Get-VmsManagementServer).Version -lt 23.1) {
                $null | Should -BeNullOrEmpty -Because "Webhooks are supported as of VMS version 2023 R1. Current version is $((Get-VmsManagementServer).Version)."
                return
            }
            $webhooks = Get-VmsWebhook
            $webhooks.Count | Should -BeGreaterThan 0
            $webhooks | Remove-VmsWebhook
            (Get-VmsWebhook).Count | Should -Be 0
        }
    }
}
