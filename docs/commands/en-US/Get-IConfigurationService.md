---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-IConfigurationService/
schema: 2.0.0
---

# Get-IConfigurationService

## SYNOPSIS

Gets an instance of an IConfigurationService WCF client.

## SYNTAX

```
Get-IConfigurationService [<CommonParameters>]
```

## DESCRIPTION

The `Get-IConfigurationService` cmdlet returns a Windows Communication
Foundation (WCF) client proxy which can be used to call various methods on the
management server. This is useful when you want to perform an action that is
not available in an existing cmdlet in the MilestonePSTools module but which is
possible using MIP SDK directly.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
$svc = Get-IConfigurationService
$svc.GetItem("/")
```

Creates an IConfigurationService client and gets the management server
ConfigurationItem object using the management server path "/".

### Example 2

```powershell
$svc = Get-IConfigurationService
$svc.GetChildItems("/") | Sort-Object DisplayName
```

Creates an IConfigurationService client and gets all the child items of the
management Server in alphabetical order by DisplayName.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.ConfigurationApi.ClientService.IConfigurationService

## NOTES

## RELATED LINKS

[MIP SDK Documentation](https://doc.developer.milestonesys.com/html/index.html?base=miphelp/interface_video_o_s_1_1_configuration_api_1_1_client_service_1_1_i_configuration_service.html&tree=tree_search.html?search=iconfigurationservice)

