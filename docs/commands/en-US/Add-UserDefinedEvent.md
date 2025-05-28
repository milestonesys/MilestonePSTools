---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-UserDefinedEvent/
schema: 2.0.0
---

# Add-UserDefinedEvent

## SYNOPSIS

Adds a new User-defined Event to the system configuration

## SYNTAX

```
Add-UserDefinedEvent [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION

The `Add-UserDefinedEvent` cmdlet adds a new User-defined Event to the system configuration. User-defined Events can be manually triggered in the Management Client or Smart Client to trigger an assigned Rule action. User-defined Events can also be triggered via a MIP integration and have associated metadata included.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Add-UserDefinedEvent -Name 'Panic'
```

Creates a new User-defined Event named Panic.

## PARAMETERS

### -Name

Specifies the name of the User-defined Event. This is the display name used in Management Client and the rules engine.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.UserDefinedEvent

## NOTES

## RELATED LINKS
