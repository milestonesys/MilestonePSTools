using namespace System.Collections.Generic

BeforeAll {
    # Must use PSScriptAnalyzer 1.20.0 or later due to a null-reference bug in one of the "ShouldProcess" tests.
    Import-Module PSScriptAnalyzer -RequiredVersion 1.20.0 -Force -ErrorAction Stop
    . $env:BHProjectPath\build.functions.ps1

    $script:docsRoot = Join-Path -Path $ENV:BHProjectPath -ChildPath 'docs/'

    $outputModVerManifest = Join-Path -Path $env:BHBuildOutput -ChildPath "$($env:BHProjectName).psd1"

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop
}

Describe 'Test PowerShell code in docs' {
    BeforeAll {
        $script:files = @{
            PowerShell = [list[hashtable]]::new()
            Markdown   = [list[hashtable]]::new()
        }
        $script:docsRoot = Join-Path -Path $ENV:BHProjectPath -ChildPath 'docs/'
        Get-ChildItem -Path $script:docsRoot -File -Recurse | ForEach-Object {
            $testCase = @{
                Name         = $_.Name
                Path         = $_.FullName
                RelativePath = $_.FullName -replace "$([regex]::Escape($ENV:BHProjectPath))\\?", ''
            }
            if ($_.Extension -eq '.md') {
                $script:files.Markdown.Add($testCase)
            } elseif ($_.Extension -In @('.ps1', '.psm1', '.psd1')) {
                $script:files.PowerShell.Add($testCase)
            }
        }
    }

    It 'PS1 files pass static analysis' {
        $pssaArgs = @{
            Path        = $null
            Settings    = 'PSGallery'
            ExcludeRule = 'PSAvoidUsingInvokeExpression'
        }
        foreach ($file in $script:files['PowerShell']) {
            $pssaArgs.Path = $file.Path
            $analysis = Invoke-ScriptAnalyzer @pssaArgs | Where-Object Severity -GE 'Warning'
            if ($analysis) {
                $source = @{
                    Name       = 'Source'
                    Expression = { '{0}:{1}:{2}' -f $file.RelativePath, $_.Line, $_.Column }
                }
                $analysis | Select-Object Severity, $Source, Message, RuleName | Out-Default
            }
            $analysis.Count | Should -Be 0
        }
    }

    It 'Markdown code passes static analysis' {
        $pssaArgs = @{
            ScriptDefinition = $null
            Settings         = 'PSGallery'
            ExcludeRule      = 'PSAvoidUsingInvokeExpression'
        }
        foreach ($file in $script:files['Markdown']) {
            foreach ($code in Get-MdCodeBlock -Path $file.Path -Language powershell -BasePath $script:docsRoot) {
                $pssaArgs.ScriptDefinition = $code.Content
                $analysis = Invoke-ScriptAnalyzer @pssaArgs | Where-Object Severity -GE 'Warning'
                if ($analysis) {
                    $source = @{
                        Name       = 'Source'
                        Expression = { '{0}:{1}:{2}' -f $file.relativePath, $code.LineNumber, $code.Position }
                    }
                    $analysis | Select-Object Severity, $Source, Message, RuleName | Out-Default
                }
                $analysis.Count | Should -Be 0
            }
        }
    }
}