---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-SpeakerSetting/
schema: 2.0.0
---

# Get-SpeakerSetting

## SYNOPSIS

Gets the settings for specified speaker.

## SYNTAX

### GeneralSettings
```
Get-SpeakerSetting -Speaker <Speaker> [-General] [-Name <String>] [-ValueInfo] [<CommonParameters>]
```

### StreamSettings
```
Get-SpeakerSetting -Speaker <Speaker> [-Stream] [-StreamNumber <Int32>] [-Name <String>] [-ValueInfo]
 [<CommonParameters>]
```

## DESCRIPTION

The `Get-SpeakerSetting` cmdlet returns a PSCustomObject with all the settings available for the specified speaker.

The values returned by this cmdlet are the "display values" that would be seen in the Management Client. To see a mapping 
of the "display values" to the raw values used by the MIP SDK, the "-ValueInfo" switch may be used.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-VmsSpeaker -Name 'Axis P3265-LVE (10.1.1.133) - Speaker 1' | Get-SpeakerSetting -General

<# OUTPUT (all values)
AudioOutputGain
---------------
0
#>
```

Gets all the speaker settings for the speaker named 'Axis P3265-LVE (10.1.1.133) - Speaker 1'. The "-General" switch is required.

### Example 2

```powershell
Get-VmsSpeaker -Name 'Axis P3265-LVE (10.1.1.133) - Speaker 1' | Get-SpeakerSetting -General -ValueInfo

<# OUTPUT (ValueInfo)
Setting         Property Value
-------         -------- -----
AudioOutputGain Mute     Mute
AudioOutputGain -30      -30
AudioOutputGain -29      -29
AudioOutputGain -28      -28
AudioOutputGain -27      -27
AudioOutputGain -26      -26
AudioOutputGain -25      -25
AudioOutputGain -24      -24
AudioOutputGain -23      -23
AudioOutputGain -22      -22
AudioOutputGain -21      -21
AudioOutputGain -20      -20
AudioOutputGain -19      -19
AudioOutputGain -18      -18
AudioOutputGain -17      -17
AudioOutputGain -16      -16
AudioOutputGain -15      -15
AudioOutputGain -14      -14
AudioOutputGain -13      -13
AudioOutputGain -12      -12
AudioOutputGain -11      -11
AudioOutputGain -10      -10
AudioOutputGain -9       -9
AudioOutputGain -8       -8
AudioOutputGain -7       -7
AudioOutputGain -6       -6
AudioOutputGain -5       -5
AudioOutputGain -4       -4
AudioOutputGain -3       -3
AudioOutputGain -2       -2
AudioOutputGain -1       -1
AudioOutputGain 0        0
AudioOutputGain 1        1
AudioOutputGain 2        2
AudioOutputGain 3        3
AudioOutputGain 4        4
AudioOutputGain 5        5
AudioOutputGain 6        6
#>
```

## PARAMETERS

### -General

Specifies that the General settings should be returned. Speakers only have General settings so this switch
is required.

```yaml
Type: SwitchParameter
Parameter Sets: GeneralSettings
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Specifies the name of the property to be returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Speaker

Specifies the Speaker to retrieve the settings of, as returned by `Get-VmsSpeaker`.

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
Default value: None
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

### -ValueInfo

Specifies that the PSCustomObject should contain a "ValueInfo" collection for each setting, 
instead of the value of the setting. The "ValueInfo" collections can be used to discover 
the valid ranges or values for each setting.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
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

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
