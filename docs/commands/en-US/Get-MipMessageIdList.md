---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-MipMessageIdList/
schema: 2.0.0
---

# Get-MipMessageIdList

## SYNOPSIS

Gets a list of all known MessageIds

## SYNTAX

```
Get-MipMessageIdList [<CommonParameters>]
```

## DESCRIPTION

Gets a list of all known MessageIds.
This includes all the message id's defined by the PlatformPlugin and environment as well as for all loaded plug-ins.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1

```powershell
Get-MipMessageIdList
```

Returns a full list of all message ID's defined in `[VideoOS.Platform.EnvironmentManager]::Instance.MessageIdList`.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
