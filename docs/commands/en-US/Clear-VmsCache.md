---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Clear-VmsCache/
schema: 2.0.0
---

# Clear-VmsCache

## SYNOPSIS
Clears any cached VMS configuration in the current PowerShell session.

## SYNTAX

```
Clear-VmsCache [<CommonParameters>]
```

## DESCRIPTION
The `Clear-VmsCache` cmdlet was introduced after MilestonePSTools began keeping
a reference to the root ManagementServer Configuration API item, and using
this common root configuration item when retrieving other objects like recording
servers, cameras, roles, events, and more. This cmdlet will dispose of any
cached configuration, including the root ManagementServer object, so that any
changes to the configuration can be retrieved.

This cmdlet is especially helpful after adding new cameras as it will also
invoke `VideoOS.Platform.SDK.Environment.ReloadConfiguration` which makes it
possible to retrieve device state, stream statistics, or retrieve live and
recorded video from devices that have been added since the call to
`Connect-Vms`

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1
```powershell
Clear-VmsCache
```

Clears the cached ManagementServer Configuration API object for the current
site, and reloads the configuration.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None
## NOTES

## RELATED LINKS
