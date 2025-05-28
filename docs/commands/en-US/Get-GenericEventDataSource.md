---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-GenericEventDataSource/
schema: 2.0.0
---

# Get-GenericEventDataSource

## SYNOPSIS

Gets Generic Event Data Sources from the currently connected XProtect VMS site.

## SYNTAX

```
Get-GenericEventDataSource [<CommonParameters>]
```

## DESCRIPTION

The `Get-GenericEventDataSource` cmdlet gets all Generic Event Data Sources from the currently connected VMS site. Generic Event
Data Sources allow you to define the following information.

- Port
- Protocol (TCP and/or UDP)
- IP type (IPv6 and/or IPv6)
- Separator bytes
- Echo type
- Encoding type
- Allowed external IPv4 and IPv6 addresses

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-GenericEventDataSource
```

Returns an object with all of the Generic Event Data Sources and their values.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.GenericEventDataSource

## NOTES

## RELATED LINKS
