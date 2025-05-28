---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-IServerCommandService/
schema: 2.0.0
---

# Get-IServerCommandService

## SYNOPSIS

Gets an instance of a ServerCommandService client.

## SYNTAX

```
Get-IServerCommandService [<CommonParameters>]
```

## DESCRIPTION

The `Get-IServerCommandService` cmdlet returns a Windows Communication
Foundation (WCF) client proxy which can be used to call various methods on the
management server. This is useful when you want to perform an action that is
not available in an existing cmdlet in the MilestonePSTools module but which is
possible using MIP SDK directly.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
$svc = Get-IServerCommandService
$svc.GetConfiguration((Get-VmsToken))
```

Returns a `VideoOS.Common.Proxy.Server.WCF.ConfigurationInfo` object which can
sometimes be easier and faster than enumerating through the configuration api
hierarchy.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Common.Proxy.Server.WCF.IServerCommandService

## NOTES

## RELATED LINKS

[MIP SDK Documentation](https://doc.developer.milestonesys.com/html/index.html?base=serversoaphelp/class_server_command_service.html&tree=tree_search.html?search=servercommandservice)

