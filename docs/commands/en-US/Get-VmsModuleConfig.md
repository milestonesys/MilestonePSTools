---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsModuleConfig/
schema: 2.0.0
---

# Get-VmsModuleConfig

## SYNOPSIS
Gets an object representing the MilestonePSTools module settings.

## SYNTAX

```
Get-VmsModuleConfig [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsModuleConfig` cmdlet gets an object representing the MilestonePSTools module settings. These settings
determine whether debug logging is enabled or disabled, and can make other minor changes to the behavior of the module.

The settings are determined based on the content of the `appsettings.json` file in the **bin** folder of the PowerShell
module. When settings are modified using `Set-VmsModuleConfig`, the customized user settings are stored in
`~\AppData\Local\Milestone\MilestonePSTools\appsettings.user.json` which takes precendce over the built-in module
settings.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1
```powershell
(Get-VmsModuleConfig).Mip.EnvironmentManager.EnvironmentOptions

<# OUTPUT
    Name                             Value
    ----                             -----
    LogPrefix                        MilestonePSTools
    ToolkitFork                      Yes
    UsePing                          No
    UseControlForMessaging           Yes
    CompanyNameFolder                Milestone
    SoftwareDecodingThreads          2,2
    ConnectionCheckTimeout           5
    ConfigurationChangeCheckInterval 300
    HardwareDecodingMode             Auto
#>
```

Displays the current values applied to `VideoOS.Platform.EnvironmentManager`.

### Example 2
```powershell
(Get-VmsModuleConfig).Mip.EnvironmentManager.DebugLoggingEnabled
```

Returns a boolean value indicating whether debug logging is enabled.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### MilestonePSTools.Models.ModuleSettings

## NOTES

## RELATED LINKS
