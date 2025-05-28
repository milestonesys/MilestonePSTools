---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-SpeakerSetting/
schema: 2.0.0
---

# Set-SpeakerSetting

## SYNOPSIS

Sets a general setting for a speaker based on the setting name/key.

## SYNTAX

### GeneralSettings
```
Set-SpeakerSetting -Speaker <Speaker> [-General] -Name <String> -Value <String> [<CommonParameters>]
```

### StreamSettings
```
Set-SpeakerSetting -Speaker <Speaker> [-Stream] [-StreamNumber <Int32>] -Name <String> -Value <String>
 [<CommonParameters>]
```

## DESCRIPTION

The `Set-SpeakerSetting` cmdlet enables settings to be updated on speakers with minimal effort.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-VmsSpeaker -Name 'Axis P3265-LVE (10.1.1.133) - Speaker 1' | Set-SpeakerSetting -General -Name AudioOutputGain -Value 5
```

Sets the "AudioOutputGain" value to 5 for the speaker named 'Axis P3265-LVE (10.1.1.133) - Speaker 1'

## PARAMETERS

### -General

Specifies that the setting applies to the General settings. This switch is required.

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

### -Speaker

Specifies the Speaker to be updated as returned by `Get-VmsSpeaker`.

```yaml
Type: Speaker
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Stream

** Not Used **

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

### VideoOS.Platform.ConfigurationItems.Speaker

## OUTPUTS

## NOTES

## RELATED LINKS
