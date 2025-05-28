---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsIServiceRegistrationService/
schema: 2.0.0
---

# Get-VmsIServiceRegistrationService

## SYNOPSIS
Gets an instance of an IServiceRegistrationService WCF client.

## SYNTAX

```
Get-VmsIServiceRegistrationService [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsIServiceRegistrationService` cmdlet returns a Windows Communication
Foundation (WCF) client for the IServiceRegistrationService management server
API. This API provides methods for retrieving, adding, updating and removing
registered services.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
$svc = Get-VmsIServiceRegistrationService
$svc.GetServices() | Select-Object Name, Description, Instance, Type
```

Gets a client for the IServiceRegistrationService API, and uses it to list some basic properties available from all
registered service entries that are currently enabled.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.Util.Svc.IServiceRegistrationService

## NOTES

This cmdlet is intended for PowerShell and .NET developers who are comfortable working directly with .NET objects. See the MIP SDK documentation for more information about the IServiceRegistrationService interface.

## RELATED LINKS

[MIP SDK Documentation - IServiceRegistrationService](https://doc.developer.milestonesys.com/html/index.html?base=miphelp/interface_video_o_s_1_1_platform_1_1_util_1_1_svc_1_1_i_service_registration_service.html)

