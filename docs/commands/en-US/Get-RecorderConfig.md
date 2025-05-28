---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-RecorderConfig/
schema: 2.0.0
---

# Get-RecorderConfig

## SYNOPSIS

Gets general information from the Recording Server configuration file.

## SYNTAX

```
Get-RecorderConfig [<CommonParameters>]
```

## DESCRIPTION

The `Get-RecorderConfig` cmdlet gets general information from the Recording Server configuration
file located at C:\ProgramData\Milestone\XProtect Recording Server\RecorderConfig.xml.

This command must be run on the Recording Server.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1

```powershell
Get-RecorderConfig
```

```Output
Version              : 25.1.0.2
InstallationPath     : C:\Program Files\Milestone\XProtect Recording Server\VideoOS.Recorder.Service.exe
ServiceInfo          : Win32_Service (Name = "Milestone XProtect Recording Server")
DevicePackPath       : C:\Program Files (x86)\Milestone\XProtect Recording Server\Drivers\NativeDrivers\
ServerCertHash       :
ClientRegistrationId : 64fb052a-45a2-4ed9-9467-2241cb4b638e
ServerAddress        : lab-xpco
ServerPort           : 9000
RecorderId           : f9dc2bcd-faea-4138-bf5a-32cd15c91f2c
AuthServerAddress    : http://lab-xpco/IDP
WebServerPort        : 7563
LocalServerPort      : 9001
AlertServerPort      : 0
```

Returns general information from the RecorderConfig.xml file.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
