@{
    PSDependOptions = @{
        Target = 'CurrentUser'
        Parameters = @{
            Scope = 'CurrentUser'
        }
    }
    'BuildHelpers' = @{
        # License: MIT
        # Purpose: Sets build environment variables
        # Url: https://github.com/RamblingCookieMonster/BuildHelpers
        Version = '2.0.16'
    }
    'PowerShellBuild' = @{
        # License: MIT
        # Purpose: Contains build tasks for PowerShell modules
        # Url: https://github.com/psake/PowerShellBuild
        Version = '0.7.2'
    }
    'Pester' = @{
        # License: Apache-2.0
        # Purpose: Testing framework for PowerShell
        # Url: https://github.com/pester/pester
        Version = '5.7.1'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }
    'PSScriptAnalyzer' = @{
        # License: MIT
        # Purpose: Static code analysis for PowerShell
        # Url: https://github.com/PowerShell/PSScriptAnalyzer
        Version = '1.20.0'
        Parameters = @{
            Scope = 'CurrentUser'
        }
    }
    'psake' = @{
        # License: MIT
        # Purpose: Build automation tool for PowerShell
        # Url: https://github.com/psake/psake
        Version = '4.9.0'
    }
    'platyPS' = @{
        # License: MIT
        # Purpose: Generate markdown and maml help files for PowerShell modules
        # Url: https://github.com/PowerShell/platyPS
        Version = '0.14.2'
        Parameters = @{
            SkipPublisherCheck = $true
        }
    }
    'VSSetup' = @{
        # License: MIT
        # Purpose: Interact with Visual Studio Setup
        # Url: https://github.com/microsoft/vssetup.powershell
        Version = '2.2.16'
    }
    'Microsoft.PowerShell.SecretManagement' = @{
        # License: MIT
        # Purpose: Secret management interface for local development and CI
        # Url: https://github.com/PowerShell/SecretManagement
        Version = '1.1.2'
    }
    'Microsoft.PowerShell.SecretStore' = @{
        # License: MIT
        # Purpose: Secret store for local development and CI
        # Url: https://github.com/PowerShell/SecretStore
        Version = '1.0.6'
        DependsOn = 'Microsoft.PowerShell.SecretManagement'
    }
    'InitializeSecretStore' = @{
        DependencyType = 'task'
        Target = 'bootstrap\Initialize-SecretStore.ps1'
        DependsOn = 'Microsoft.PowerShell.SecretStore'
    }
    'Chocolatey' = @{
        # License: Apache-2.0
        # Purpose: Package manager for Windows
        # Url: https://github.com/chocolatey/choco
        DependencyType = 'task'
        Target = 'bootstrap\Install-Chocolatey.ps1'
    }
    'VSBuildTools' = @{
        # License: Proprietary
        # Purpose: Build tools for Visual Studio
        # Url: https://visualstudio.microsoft.com/license-terms/vs2022-ga-diagnosticbuildtools/
        DependencyType = 'task'
        Target = 'bootstrap\Install-VSBuildTools.ps1'
        DependsOn = 'VSSetup'
    }
}
