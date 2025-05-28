Context 'Assert-VmsRequirementsMet' -Skip:($script:SkipReadWriteTests) {
    Describe 'IVmsRequirementValidator' {
        It 'Assert-VmsRequirementsMet is called in begin block for functions with requirements' {
            Get-Command -Module MilestonePSTools -CommandType Function | Where-Object {
                $_.Name -ne 'Assert-VmsRequirementsMet' -and ($_.ScriptBlock.Attributes | Where-Object {
                    $null -ne ($_ -as [MilestonePSTools.IVmsRequirementValidator])
                })
            } | ForEach-Object {
                $assert = $_.ScriptBlock.Ast.FindAll({$null -ne ($args[0] -as [System.Management.Automation.Language.CommandAst])}, $true) | Where-Object { $_.GetCommandName() -match 'Assert-VmsRequirementsMet' }
                $assert.Count | Should -Be 1 -Because "$($_.Name) must call Assert-VmsRequirementsMet 1 time"
                $assert.Parent.Parent.BlockKind | Should -Be 'Begin' -Because "$($_.Name) must call Assert-VmsRequirementsMet in the begin block"
            }
        }
    }

    Describe 'RequiresVmsVersion Validation Errors' {
        BeforeAll {
            $script:vmsVersion = [version](Get-VmsManagementServer).Version
        }

        It 'BasicPattern throws when version is less than MinVersion' {
            Invoke-Expression -Command 'function ThrowsTerminatingError { [CmdletBinding()][MilestonePSTools.RequiresVmsVersion("999.999.999")]param() begin { Assert-VmsRequirementsMet } process { $true } }'
            { ThrowsTerminatingError } | Should -Throw
        }

        It 'AdvancedPattern throws when version is greater than MaxVersion Inclusive' {
            $testVersion = [version]::new($script:vmsVersion.Major, $script:vmsVersion.Minor, $script:vmsVersion.Build, $script:vmsVersion.Revision - 1)
            Invoke-Expression -Command "function ThrowsTerminatingError { [CmdletBinding()][MilestonePSTools.RequiresVmsVersion('[,$testVersion]')]param() begin { Assert-VmsRequirementsMet } process { `$true } }"
            { ThrowsTerminatingError } | Should -Throw
        }

        It 'AdvancedPattern throws when version is greater than MaxVersion Exclusive' {
            Invoke-Expression -Command "function ThrowsTerminatingError { [CmdletBinding()][MilestonePSTools.RequiresVmsVersion('[,$script:vmsVersion)')]param() begin { Assert-VmsRequirementsMet } process { `$true } }"
            { ThrowsTerminatingError } | Should -Throw
        }

        It 'AdvancedPattern throws when version is less than MinVersion Inclusive' {
            $testVersion = [version]::new($script:vmsVersion.Major, $script:vmsVersion.Minor, $script:vmsVersion.Build, $script:vmsVersion.Revision + 1)
            Invoke-Expression -Command "function ThrowsTerminatingError { [CmdletBinding()][MilestonePSTools.RequiresVmsVersion('[$testVersion,]')]param() begin { Assert-VmsRequirementsMet } process { `$true } }"
            { ThrowsTerminatingError } | Should -Throw
        }

        It 'AdvancedPattern throws when version is less than MinVersion Exclusive' {
            Invoke-Expression -Command "function ThrowsTerminatingError { [CmdletBinding()][MilestonePSTools.RequiresVmsVersion('($script:vmsVersion,]')]param() begin { Assert-VmsRequirementsMet } process { `$true } }"
            { ThrowsTerminatingError } | Should -Throw
        }

        It 'ExactPattern throws when version is not exactly 0.0.1' {
            Invoke-Expression -Command 'function ThrowsTerminatingError { [CmdletBinding()][MilestonePSTools.RequiresVmsVersion("[0.0.1]")]param() begin { Assert-VmsRequirementsMet } process { $true } }'
            { ThrowsTerminatingError } | Should -Throw
        }
    }

    Describe 'RequiresVmsVersion Validation Passes' {
        BeforeAll {
            $script:vmsVersion = [version](Get-VmsManagementServer).Version
        }

        It 'BasicPattern' {
            Invoke-Expression -Command "function NoVersionError { [CmdletBinding()][MilestonePSTools.RequiresVmsVersion('$script:vmsVersion')]param() begin { Assert-VmsRequirementsMet } process { `$true } }"
            { NoVersionError } | Should -Not -Throw
            NoVersionError | Should -BeTrue
        }

        It 'AdvancedPattern MaxVersion Inclusive' {
            Invoke-Expression -Command "function NoVersionError { [CmdletBinding()][MilestonePSTools.RequiresVmsVersion('[,$script:vmsVersion]')]param() begin { Assert-VmsRequirementsMet } process { `$true } }"
            { NoVersionError } | Should -Not -Throw
            NoVersionError | Should -BeTrue
        }

        It 'AdvancedPattern MaxVersion Exclusive' {
            $testVersion = [version]::new($script:vmsVersion.Major, $script:vmsVersion.Minor, $script:vmsVersion.Build, $script:vmsVersion.Revision + 1)
            Invoke-Expression -Command "function NoVersionError { [CmdletBinding()][MilestonePSTools.RequiresVmsVersion('[,$testVersion)')]param() begin { Assert-VmsRequirementsMet } process { `$true } }"
            { NoVersionError } | Should -Not -Throw
            NoVersionError | Should -BeTrue
        }

        It 'AdvancedPattern MinVersion Inclusive' {
            Invoke-Expression -Command "function NoVersionError { [CmdletBinding()][MilestonePSTools.RequiresVmsVersion('[$script:vmsVersion,]')]param() begin { Assert-VmsRequirementsMet } process { `$true } }"
            { NoVersionError } | Should -Not -Throw
            NoVersionError | Should -BeTrue
        }

        It 'AdvancedPattern MinVersion Exclusive' {
            $testVersion = [version]::new($script:vmsVersion.Major, $script:vmsVersion.Minor, $script:vmsVersion.Build, $script:vmsVersion.Revision - 1)
            Invoke-Expression -Command "function NoVersionError { [CmdletBinding()][MilestonePSTools.RequiresVmsVersion('($testVersion,]')]param() begin { Assert-VmsRequirementsMet } process { `$true } }"
            { NoVersionError } | Should -Not -Throw
            NoVersionError | Should -BeTrue
        }

        It 'ExactPattern' {
            Invoke-Expression -Command "function NoVersionError { [CmdletBinding()][MilestonePSTools.RequiresVmsVersion('[$script:vmsVersion]')]param() begin { Assert-VmsRequirementsMet } process { `$true } }"
            { NoVersionError } | Should -Not -Throw
            NoVersionError | Should -BeTrue
        }
    }
}
