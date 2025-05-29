@{
    'BuildHelpers' = @{
        Version = '2.0.16'
    }
    'PowerShellBuild' = @{
        Version = '0.7.2'
    }
    Pester           = @{
        Version    = '5.7.1'
    }

    psake            = @{
        Version    = '4.9.0'
    }

    PSScriptAnalyzer = @{
        Version = '1.21.0'
    }

    platyPS          = @{
        Version    = '0.14.2'
    }

    PowerHTML          = @{
        Version    = '0.2.0'
    }

    'Microsoft.PowerShell.SecretManagement' = @{
        Version = '1.1.2'
    }
    
    'Microsoft.PowerShell.SecretStore' = @{
        Version = '1.0.6'
        DependsOn = 'Microsoft.PowerShell.SecretManagement'
    }
    
    'InitializeSecretStore' = @{
        DependencyType = 'task'
        Target = 'bootstrap\Initialize-SecretStore.ps1'
        DependsOn = 'Microsoft.PowerShell.SecretStore'
    }
}
