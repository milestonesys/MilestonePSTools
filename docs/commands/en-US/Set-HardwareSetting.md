---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-HardwareSetting/
schema: 2.0.0
---

# Set-HardwareSetting

## SYNOPSIS

Sets the hardware settings for the specified Hardware.

## SYNTAX

```
Set-HardwareSetting -Hardware <Hardware> [-Name] <String> [-Value] <String> [<CommonParameters>]
```

## DESCRIPTION

The `Set-HardwareSetting` cmdlet configures the value on the specified setting.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-VmsHardware -Name 'Axis P3265-LVE (10.1.1.133)' | Set-HardwareSetting -Name HTTPSPort -Value 444
```

Sets the HTTPS port to 444 for the hardware named 'Axis P3265-LVE (10.1.1.133)'

## PARAMETERS

### -Hardware

Specifies the Hardware to be updated as returned by `Get-VmsHardware`.

```yaml
Type: Hardware
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name

Specifies the name of the property to be updated.

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

### -Value

Specifies the value for updating the specified property.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Hardware

## OUTPUTS

## NOTES

## RELATED LINKS
