# Taken with love from @juneb_get_help (https://raw.githubusercontent.com/juneb/PesterTDD/master/Module.Help.Tests.ps1)

BeforeDiscovery {
    function script:FilterOutCommonAndDontShowParams {
        param ($Params)
        $commonParams = @(
            'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable',
            'OutBuffer', 'OutVariable', 'PipelineVariable', 'Verbose', 'WarningAction',
            'WarningVariable', 'Confirm', 'Whatif'
        )
        
        $params | Where-Object {
            $parameterAttribute = $_.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
            $_.Name -notin $commonParams -and $parameterAttribute.DontShow -eq $false
        } | Sort-Object -Property Name -Unique
    }

    $outputModVerManifest = Join-Path -Path $env:BHBuildOutput -ChildPath "$($env:BHProjectName).psd1"

    # Get module commands
    # Remove all versions of the module from the session. Pester can't handle multiple versions.
    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module -Name $outputModVerManifest -Verbose:$false -ErrorAction Stop
    $params = @{
        Module      = (Get-Module $env:BHProjectName)
        CommandType = [System.Management.Automation.CommandTypes[]]'Cmdlet, Function' # Not alias
    }
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        $params.CommandType[0] += 'Workflow'
    }
    $commands = Get-Command @params

    ## When testing help, remember that help is cached at the beginning of each session.
    ## To test, restart session.
}

Describe "Test help for <_.Name>" -ForEach $commands {

    BeforeDiscovery {
        function script:FilterOutCommonAndDontShowParams {
            param ($Params)
            $commonParams = @(
                'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable',
                'OutBuffer', 'OutVariable', 'PipelineVariable', 'Verbose', 'WarningAction',
                'WarningVariable', 'Confirm', 'Whatif'
            )
            
            $params | Where-Object {
                $parameterAttribute = $_.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
                $_.Name -notin $commonParams -and $parameterAttribute.DontShow -eq $false
            } | Sort-Object -Property Name -Unique
        }

        # Get command help, parameters, and links
        $command               = $_
        $commandHelp           = Get-Help $command.Name -ErrorAction SilentlyContinue
        $commandParameters     = script:FilterOutCommonAndDontShowParams -Params $command.ParameterSets.Parameters
        $commandParameterNames = $commandParameters.Name
    }

    BeforeAll {

        function script:FilterOutCommonAndDontShowParams {
            param ($Params)
            $commonParams = @(
                'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable',
                'OutBuffer', 'OutVariable', 'PipelineVariable', 'Verbose', 'WarningAction',
                'WarningVariable', 'Confirm', 'Whatif'
            )
            
            $params | Where-Object {
                $parameterAttribute = $_.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
                $_.Name -notin $commonParams -and $parameterAttribute.DontShow -eq $false
            } | Sort-Object -Property Name -Unique
        }

        # These vars are needed in both discovery and test phases so we need to duplicate them here
        $command                = $_
        $commandHelp            = Get-Help $command.Name -ErrorAction SilentlyContinue
        $commandParameters      = script:FilterOutCommonAndDontShowParams -Params $command.ParameterSets.Parameters
        $commandParameterNames  = $commandParameters.Name
        $helpParameters         = script:FilterOutCommonAndDontShowParams -Params $commandHelp.Parameters.Parameter
        $helpParameterNames     = $helpParameters.Name
    }

    # If help is not found, synopsis in auto-generated help is the syntax diagram
    It 'Help is not auto-generated' {
        $commandHelp.Synopsis | Should -Not -BeLike '*`[`<CommonParameters`>`]*'
    }

    # Should be a description for every function
    It "Has description" {
        $commandHelp.Description | Should -Not -BeNullOrEmpty
    }

    # Should be at least one example
    It "Has example code" {
        ($commandHelp.Examples.Example | Select-Object -First 1).Code | Should -Not -BeNullOrEmpty
    }

    # Should be at least one example description
    It "Has example help" {
        ($commandHelp.Examples.Example.Remarks | Select-Object -First 1).Text | Should -Not -BeNullOrEmpty
    }

    Context "Parameter <_.Name>" -Foreach $commandParameters {

        BeforeAll {
            $parameter         = $_
            $parameterName     = $parameter.Name
            $parameterHelp     = $commandHelp.parameters.parameter | Where-Object Name -eq $parameterName
            $parameterHelpType = if ($parameterHelp.ParameterValue) { $parameterHelp.ParameterValue.Trim() }
        }

        # Should be a description for every parameter
        It "Has description" {
            $parameterHelp.Description.Text | Should -Not -BeNullOrEmpty
        }

        # Required value in Help should match IsMandatory property of parameter
        It "Has correct [mandatory] value" {
            $codeMandatory = $_.IsMandatory.toString()
            $parameterHelp.Required | Should -Be $codeMandatory
        }

        # Parameter type in help should match code
        It "Has correct parameter type" {
            # Modified this test because my Int32 parameters from the C# project, once imported, seem to get converted to Nullable[int32] an
            # this test fails with...
            # Expected: 'Nullable`1'
            # But was:  'Int32'
            if ($parameter.ParameterType.Name -eq 'Nullable`1') {
                $parameterHelpType | Should -Be $parameter.ParameterType.GenericTypeArguments.Name
            }
            else {
                $parameterHelpType | Should -Be $parameter.ParameterType.Name
            }
        }
    }

    Context "Test <_> help parameter help for <commandName>" -Foreach $helpParameterNames {

        # Shouldn't find extra parameters in help.
        It "finds help parameter in code: <_>" {
            $_ -in $parameterNames | Should -Be $true
        }
    }
}
