---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-ManagementServerConfig/
schema: 2.0.0
---

# Get-ManagementServerConfig

## SYNOPSIS

Gets general information from the Management Server configuration file.

## SYNTAX

```
Get-ManagementServerConfig [<CommonParameters>]
```

## DESCRIPTION

The `Get-ManagementServerConfig` cmdlet gets general information from the Management Server
configuration file located at C:\ProgramData\Milestone\XProtect Management Server\ServerConfig.xml.

This command must be run on the Management Server.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1

```powershell
Get-ManagementServerConfig
```

```Output
AuthServerAddress    : http://lab-xpco/IDP
Version              : 25.1.0.2
InstallationPath     : C:\Program Files\Milestone\XProtect Management Server\VideoOS.Server.Service.exe
WebApiPort           : 9000
ServerCertHash       :
ServiceInfo          : Win32_Service (Name = "Milestone XProtect Management Server")
ClientRegistrationId : 6c593bd6-b3df-477b-8e1d-56839c6b13c8
```

Returns general information from the ServerConfig.xml file.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
