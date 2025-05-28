---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-GenericEvent/
schema: 2.0.0
---

# Get-GenericEvent

## SYNOPSIS

Gets Generic Events from the currently connected XProtect VMS site.

## SYNTAX

```
Get-GenericEvent [<CommonParameters>]
```

## DESCRIPTION

The `Get-GenericEvent` cmdlet gets all Generic Events from the currently connected VMS site.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-GenericEvent
```

Get all Generic Events in the XProtect system.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.GenericEvent

## NOTES

## RELATED LINKS
