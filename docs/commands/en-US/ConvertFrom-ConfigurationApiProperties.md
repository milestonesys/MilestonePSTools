---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/ConvertFrom-ConfigurationApiProperties/
schema: 2.0.0
---

# ConvertFrom-ConfigurationApiProperties

## SYNOPSIS

Converts a complex Milestone Configuration API propery collection into a hashtable

## SYNTAX

```
ConvertFrom-ConfigurationApiProperties [-Properties] <ConfigurationApiProperties> [-UseDisplayNames]
 [<CommonParameters>]
```

## DESCRIPTION

When accessing property collections like $hardware.HardwareDriverSettingsFolder.HardwareDriverSettings\[0\].HardwareDriverSettingsChildItems\[0\]
it can be difficult to figure out how to access the values, and how to find the display names of those
values for "enum" style properties.
The property keys also have verbose names like
stream:0.0.1/FPS/\<guid\> for example.

This function accepts a property collection, and returns a hashtable with easy to read key names, and
either raw values, or "display" values.

If Get-Culture returns anything other than en-US, and you use the UseDisplayNames switch, a translated
value will be provided if available.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
ConvertFrom-ConfigurationApiProperties -Properties (Get-VmsHardware | Select-Object -First 1).HardwareDriverSettingsFolder.HardwareDriverSettings[0].HardwareDriverSettingsChildItems[0].Properties -UseDisplayNames
```

Gets general settings properties from the first hardware device returned by Get-VmsHardware, and returns a hashtable with the keys and display values.

## PARAMETERS

### -Properties

Specifies a Properties collection as found on $hardware.HardwareDriverSettingsFolder.HardwareDriverSettings\[0\].HardwareDriverSettingsChildItems\[0\]

```yaml
Type: ConfigurationApiProperties
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -UseDisplayNames

Specifies that the display name for each value should be returned.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
