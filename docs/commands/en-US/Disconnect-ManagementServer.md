---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Disconnect-ManagementServer/
schema: 2.0.0
---

# Disconnect-ManagementServer

## SYNOPSIS

Disconnects from all Milestone XProtect Management Servers currently logged into.

## SYNTAX

```
Disconnect-ManagementServer [<CommonParameters>]
```

## DESCRIPTION

The Disconnect-ManagementServer cmdlet should be called after you finish working with your VMS.
Gracefully closing the connection will help ensure resources are released both locally and remotely.

Note: You cannot selectively disconnect from one out of many Management Servers.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
Disconnect-ManagementServer
```

Disconnect from the current Management Server and all child sites if applicable.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
