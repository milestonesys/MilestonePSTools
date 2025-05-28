Context "VmsRule Cmdlets" -Skip:($Script:SkipReadWriteTests) {
    Context 'New-VmsRule' {
        It 'Can create new rule' {
            $ruleParams = @{
                Name        = 'VmsRule Test'
                Properties  = @{
                    'Description'               = 'Test Start Feed Rule Description'

                    'StartRuleType'             = 'TimeInterval'
                    'Always'                    = 'True'

                    'StartActions'              = 'StartFeed'
                    'Start.StartFeed.DeviceIds' = 'CameraGroup[0e1b0ad3-f67c-4d5f-b792-4bd6c3cf52f8]'

                    'StopRuleType'              = 'TimeInterval'
                    'StopActions'               = 'StopFeed'
                }
                ErrorAction = 'Stop'
            }
            $script:rule = New-VmsRule @ruleParams
            $rule.DisplayName | Should -BeExactly $ruleParams.Name
            $rule | Should -BeOfType ([VideoOS.ConfigurationApi.ClientService.ConfigurationItem])
        }
    }

    Context 'Get-VmsRule' {
        It 'Can get a list of rules' {
            $rules = Get-VmsRule
            $rules.Count | Should -BeGreaterThan 0
            $rules | Where-Object Path -eq $script:rule.Path | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Set-VmsRule' {
        It 'Can update existing rule' {
            $setVmsRuleParams = @{
                Name        = 'VmsRule Renamed'
                Enabled     = $false
                Properties  = @{
                    'Always'          = 'False'
                    'DaysOfWeek'      = 'True'
                    'DaysOfWeek.Days' = 'Monday'
                }
                ErrorAction = 'Stop'
                PassThru    = $true
            }
            $updatedRule = $script:rule | Set-VmsRule @setVmsRuleParams
            $updatedRule.DisplayName | Should -BeExactly $setVmsRuleParams.Name
            $updatedRule.EnableProperty.Enabled | Should -Be $setVmsRuleParams.Enabled
            $updatedRule | Get-ConfigurationItemProperty -Key 'DaysOfWeek.Days' | Should -BeExactly $setVmsRuleParams.Properties['DaysOfWeek.Days']
        }

        It 'Does not throw when properties do not change' {
            $properties = @{}
            $script:rule.Properties | ForEach-Object {
                $properties[$_.Key] = $_.Value
            }
            {
                $script:rule | Set-VmsRule -Properties $properties -ErrorAction Stop
            } | Should -Not -Throw
        }

        It 'Does not change rule when using WhatIf' {
            $originalRule = Get-VmsRule | Where-Object Path -eq $script:rule.Path
            $setVmsRuleParams = @{
                Name        = 'VmsRule WhatIf'
                Enabled     = !$originalRule.EnableProperty.Enabled
                Properties  = @{
                    'Always'          = 'False'
                    'DaysOfWeek'      = 'True'
                    'DaysOfWeek.Days' = 'Monday'
                }
                ErrorAction = 'Stop'
                PassThru    = $true
                WhatIf      = $true
            }
            $updatedRule = $script:rule | Set-VmsRule @setVmsRuleParams
            $updatedRule.DisplayName | Should -BeExactly $originalRule.DisplayName
            $updatedRule.EnableProperty.Enabled | Should -Be $originalRule.EnableProperty.Enabled
            $updatedRule | Get-ConfigurationItemProperty -Key 'DaysOfWeek.Days' | Should -BeExactly ($originalRule | Get-ConfigurationItemProperty -Key 'DaysOfWeek.Days')
        }
    }

    Context 'Export-VmsRule' {
        It 'Can export rule' {
            $exportPathOneRule = Join-Path -Path $env:TEMP -ChildPath 'Rules.integration.onerule.json'
            $exportPathAllRules = Join-Path -Path $env:TEMP -ChildPath 'Rules.integration.allrules.json'
            $id = $script:rule | Get-ConfigurationItemProperty -Key Id
            $oneRule = Get-VmsRule -Id $id | Export-VmsRule -PassThru -Path $exportPathOneRule -Force
            $allRules = Get-VmsRule | Export-VmsRule -PassThru -Path $exportPathAllRules -Force

            $oneRule | Should -Not -BeNullOrEmpty
            $oneRule.Count | Should -Not -BeGreaterThan 1
            $allRules.Count | Should -BeGreaterThan 1

            ((Get-Content -Path $exportPathOneRule -Raw) | ConvertFrom-Json).Count | Should -Be 1
            ((Get-Content -Path $exportPathAllRules -Raw) | ConvertFrom-Json).Count | Should -Be $allRules.Count
        }

        It 'Requires the Force switch to overwrite a file' {
            $testPath = Join-Path -Path $env:TEMP -ChildPath 'Rules.integration.export-test.json'
            $null = New-Item -Path $testPath -ItemType File -Force
            { Get-VmsRule | Select-Object -First 1 | Export-VmsRule -Path $testPath -ErrorAction Stop } | Should -Throw
            { Get-VmsRule | Select-Object -First 1 | Export-VmsRule -Path $testPath -Force -ErrorAction Stop } | Should -Not -Throw
            (Get-Item -Path $testPath).Length | Should -BeGreaterThan 0
        }
    }

    Context 'Import-VmsRule' {
        It 'Can import rule by InputObject' {
            $id = $script:rule | Get-ConfigurationItemProperty -Key Id
            $originalRule = Get-VmsRule -Id $id
            $inputObject = $originalRule | Export-VmsRule -PassThru

            $newRule = $inputObject | Import-VmsRule
            $newRule.DisplayName | Should -BeExactly $originalRule.DisplayName
            $newRule.Path | Should -Not -Be $originalRule.Path
        }

        It 'Can import rule by Path' {
            $exportPathOneRule = Join-Path -Path $env:TEMP -ChildPath 'Rules.integration.onerule.json'
            $id = $script:rule | Get-ConfigurationItemProperty -Key Id
            $originalRule = Get-VmsRule -Id $id
            $originalRule | Export-VmsRule -Path $exportPathOneRule -Force

            $newRule = Import-VmsRule -Path $exportPathOneRule
            $newRule.DisplayName | Should -BeExactly $originalRule.DisplayName
            $newRule.Path | Should -Not -Be $originalRule.Path
        }
    }

    Context 'Remove-VmsRule' {
        It 'Can remove a rule' {
            $script:rule | Remove-VmsRule -Confirm:$false
            Get-VmsRule | Where-Object Path -eq $script:rule.Path | Should -BeNullOrEmpty
        }
    }

    AfterAll {
        Get-VmsRule | Where-Object DisplayName -match '^VmsRule' | Remove-VmsRule -Confirm:$false
    }
}
