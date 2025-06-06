---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/ConvertFrom-ConfigurationItem/
schema: 2.0.0
---

# ConvertFrom-ConfigurationItem

## SYNOPSIS

Converts a generic Configuration API item to the strongly-typed version of that object type.

## SYNTAX

```
ConvertFrom-ConfigurationItem [-Path] <String> [-ItemType] <String> [<CommonParameters>]
```

## DESCRIPTION

Converts a generic Configuration API item to the strongly-typed version of that object type.
For
example, a Configuration Item representing a camera has an ItemType of Camera, and a path like
'Camera\[a6756a0e-886a-4050-a5a5-81317743c32a\]'.
Some commands require a strongly-typed Camera
object as a parameter, so if you have a generic item like you get from Find-ConfigurationItem or
Get-ConfigurationItem, you can convert that item to a strongly typed class by piping that item to
ConvertFrom-ConfigurationItem.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Find-ConfigurationItem -ItemType Camera -EnableFilter Enabled | ConvertFrom-ConfigurationItem
```

Finds all enabled cameras and converts them to Camera objects.
This should work faster than 'Get-VmsHardware | Where-Object Enabled | Get-VmsCamera | Where-Object Enabled'

## PARAMETERS

### -ItemType

Specifies the Milestone 'ItemType' value such as 'Camera', 'Hardware', or 'InputEvent'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path

Specifies the Milestone Configuration API 'Path' value of the configuration item.
For example, 'Hardware\[a6756a0e-886a-4050-a5a5-81317743c32a\]' where the guid is the ID of an existing Hardware item.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.IConfigurationItem

## NOTES

Not all ItemType's available through the Configuration API have matching "strongly typed" classes, so for less commonly used item types, you may see an error when using this function.

## RELATED LINKS
