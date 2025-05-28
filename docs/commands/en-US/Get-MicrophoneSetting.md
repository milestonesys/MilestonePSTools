---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-MicrophoneSetting/
schema: 2.0.0
---

# Get-MicrophoneSetting

## SYNOPSIS

Gets the general or stream settings for specified microphone.

## SYNTAX

### GeneralSettings
```
Get-MicrophoneSetting -Microphone <Microphone> [-General] [-Name <String>] [-ValueInfo] [<CommonParameters>]
```

### StreamSettings
```
Get-MicrophoneSetting -Microphone <Microphone> [-Stream] [-StreamNumber <Int32>] [-Name <String>] [-ValueInfo]
 [<CommonParameters>]
```

## DESCRIPTION

The `Get-MicrophoneSetting` cmdlet returns a PSCustomObject with the general or stream settings available for the specified metadata.

The values returned by this cmdlet are the "display values" that would be seen in the Management Client. To see a mapping 
of the "display values" to the raw values used by the MIP SDK, the "-ValueInfo" switch may be used.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-VmsMicrophone -Name 'Axis P3265-LVE (10.1.1.133) - Microphone 1' | Get-MicrophoneSetting -General

<# OUTPUT (general values)
AudioEncoding          : aac-48000-32000
AudioInputGain         : 50
AudioSource            : Microphone
MicrophonePower        : true
MicrophonePowerType    : 5.0V
EdgeStorageStreamIndex : 0
EdgeStorageEnabled     : False
#>
```

Gets the general settings for the microphone named 'Axis P3265-LVE (10.1.1.133) - Microphone 1'.

### Example 2

```powershell
$microphone = Get-VmsMicrophone -Name 'Axis P3265-LVE (10.1.1.133) - Microphone 1'
Get-MicrophoneSetting -Microphone $microphone -Stream -Name AudioStreamingMode

<# OUTPUT (stream value)
AudioStreamingMode
------------------
HTTP
#>
```

Gets the stream setting value for AudioStreamingMode for the microphone named 'Axis P3265-LVE (10.1.1.133) - Microphone 1'.

### Example 3

```powershell
Get-VmsMicrophone -Name 'Axis P3265-LVE (10.1.1.133) - Microphone 1' | Get-MicrophoneSetting -Stream -ValueInfo

<# OUTPUT (ValueInfo)
Setting              Property                 Value
-------              --------                 -----
EdgeStorageSupported true                     True
EdgeStorageSupported false                    False
AudioStreamingMode   RTP/UDP                  UDP
AudioStreamingMode   RTP/RTSP/TCP             TCP
AudioStreamingMode   RTP/RTSP/HTTP/TCP        HTTP
AudioStreamingMode   RTP/UDP multicast        RTP_MULTICAST
AudioStreamingMode   SRTP/RTSPS/UDP           SRTP
AudioStreamingMode   SRTP/RTSPS/UDP multicast SRTP_MULTICAST
AudioStreamingMode   SRTP/RTSPS/TCP           SRTP_TCP
#>
```

Gets the mapping of display values to the raw values. Sometimes the raw value is different from the
value that is displayed in the Management Client. When setting a value, the raw value has to be used.

## PARAMETERS

### -General

Specifies that the General settings should be returned.

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

### -Microphone

Specifies the Microphone to retrieve the settings of, as returned by `Get-VmsMicrophone`.

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

### -Stream

Specifies that the Stream settings should be returned.

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

### VideoOS.Platform.ConfigurationItems.Microphone

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
