---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-MicrophoneSetting/
schema: 2.0.0
---

# Set-MicrophoneSetting

## SYNOPSIS

Sets a general or stream setting for a microphone based on the setting name/key.

## SYNTAX

### GeneralSettings
```
Set-MicrophoneSetting -Microphone <Microphone> [-General] -Name <String> -Value <String> [<CommonParameters>]
```

### StreamSettings
```
Set-MicrophoneSetting -Microphone <Microphone> [-Stream] [-StreamNumber <Int32>] -Name <String> -Value <String>
 [<CommonParameters>]
```

## DESCRIPTION

The `Set-MicrophoneSetting` cmdlet enables settings to be updated on metadatas with minimal effort.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-VmsMicrophone -Name 'Axis P3265-LVE (10.1.1.133) - Microphone 1' | Set-MicrophoneSetting -General -Name AudioInputGain -Value 50
```

Sets the "AudioInputGain" value in General settings to 50 for the microphone named 'Axis P3265-LVE (10.1.1.133) - Microphone 1'

### Example 2

```powershell
Get-VmsMicrophone -Name 'Axis P3265-LVE (10.1.1.133) - Microphone 1' | Set-MicrophoneSetting -Stream -Name AudioStreamingMode -Value TCP
```

Sets the "AudioStreamingMode" value in Stream settings to "TCP" for the microphone named 'Axis P3265-LVE (10.1.1.133) - Microphone 1'

## PARAMETERS

### -General

Specifies that the setting applies to the General settings, as opposed to the Stream settings.

```yaml
Type: SwitchParameter
Parameter Sets: GeneralSettings
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Microphone

Specifies the Microphone to be updated as returned by `Get-VmsMicrophone`.

```yaml
Type: Microphone
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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Stream

Specifies that the setting applies to the Stream settings, as opposed to the General settings.

```yaml
Type: SwitchParameter
Parameter Sets: StreamSettings
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -StreamNumber

** Not Used **

```yaml
Type: Int32
Parameter Sets: StreamSettings
Aliases:

Required: False
Position: Named
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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Microphone

## OUTPUTS

## NOTES

## RELATED LINKS
