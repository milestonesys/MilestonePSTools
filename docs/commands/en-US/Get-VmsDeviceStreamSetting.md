---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsDeviceStreamSetting/
schema: 2.0.0
---

# Get-VmsDeviceStreamSetting

## SYNOPSIS
Gets the stream settings for one or more devices.

## SYNTAX

### Device (Default)
```
Get-VmsDeviceStreamSetting [-Device] <IConfigurationItem> [-StreamName <String>] [-RawValues] [-ValueTypeInfo]
 [<CommonParameters>]
```

### Id
```
Get-VmsDeviceStreamSetting [-Id] <Guid> [-StreamName <String>] [-RawValues] [-ValueTypeInfo]
 [<CommonParameters>]
```

### Path
```
Get-VmsDeviceStreamSetting [-Path] <String> [-StreamName <String>] [-RawValues] [-ValueTypeInfo]
 [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsDeviceStreamSetting` cmdlet returns one or more `VmsStreamSettings` records with all
the stream settings available for each stream on a device. Stream settings often include properties like
"Codec", "FPS", and "Resolution".

Each device make and model may have a different set of stream settings. For example, one camera
may have an "FPS" property while another has a property named "Framerate". Furthermore, the values
expected for a common property name like "Codec" may vary. For example, one camera may require the
value "h.264" while another may require the value "3" for the same codec. You can inspect these
values by calling `Get-VmsDeviceStreamSetting` with the `-ValueTypeInfo` switch.

By default, the values returned by this cmdlet are the "display values" you see in the Management
Client. To see the raw, internal values used by the MIP SDK, you may use the "-RawValues" switch.

The output object type is `[MilestonePSTools.DeviceCommands.VmsStreamSettings]` and it includes the
following properties: Device, StreamName, Settings, and Path. The **Settings** hashtables on these
objects can be modified directly, and piped to `Set-VmsDeviceStreamSetting` if you prefer, or you can
create your own hashtable to supply for the **Settings** hashtable when calling `Set-VmsDeviceStreamSetting`.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1: List all streams on a camera
```powershell
# Get one random enabled camera
$camera = Get-VmsCamera | Get-Random

# List all streams available with a preview of the available settings for each
$camera | Get-VmsDeviceStreamSetting
```

```Output
Device   StreamName      Settings
------   ----------      --------
Doorbell Video stream 01 MaxGOPSize=30, Protocol=RTP/RTSP/TCP, Resolution=2560x1920, MulticastForceSSM=No, StreamReferenceId=2...
Doorbell Video stream 02 MaxGOPSize=40, Protocol=RTP/RTSP/TCP, Resolution=640x480, MulticastForceSSM=No, StreamReferenceId=28D...
```

Get a random camera and display all streams available on it.

### Example 2: Show stream settings for a microphone
```powershell
# Get one random enabled microphone
$mic = Get-VmsMicrophone | Get-Random

# Show the contents of the Settings hashtable property 
($mic | Get-VmsDeviceStreamSetting).Settings
```

```Output
Name                           Value
----                           -----
MulticastPort                  25320
MulticastAddress               238.255.255.255
StreamReferenceId              F6A2936D-D0B8-4487-AE76-F7D0E83E6C83
Protocol                       RTP/RTSP/TCP
EdgeStorageSupported           false
AudioInCodecBitrateSamplerate  MP4A-LATM, 64 kbps, 16 kHz
```

Show all stream settings for a random microphone.

### Example 3: Show stream settings for a microphone with raw values
```powershell
# Get one random enabled microphone
$mic = Get-VmsMicrophone | Get-Random

# Show the contents of the Settings hashtable property with raw values
($mic | Get-VmsDeviceStreamSetting -RawValues).Settings
```

```Output
Name                           Value
----                           -----
MulticastPort                  25320
MulticastAddress               238.255.255.255
StreamReferenceId              F6A2936D-D0B8-4487-AE76-F7D0E83E6C83
Protocol                       2
EdgeStorageSupported           False
AudioInCodecBitrateSamplerate  2,64,16
```

Show all stream settings for a random microphone. Notice that compared to [Example 2](#example-2-show-stream-settings-for-a-microphone)
the **Protocol** and **AudioInCodecBitrateSamplerate** settings display internal values that are less readable. These
are the actual values stored for these settings in the VMS.

### Example 4: Show all valid values for a specific speaker stream setting
```powershell
# Get one random enabled speaker
$speaker = Get-VmsSpeaker | Get-Random

# Populate the Settings hashtable with the ValueTypeInfo collections of each
# setting and show the allowed values for the "AudioOutStreamingProto" property
($speaker | Get-VmsDeviceStreamSetting -ValueTypeInfo).Settings.AudioOutStreamingProto
```

```Output
Name         Value
----         -----
RTP/UDP      0
RTP/RTSP/TCP 2
```

Show the allowed values for a specific speaker stream property - in this case a property named "AudioOutStreamingProto".
The **Name** column shows the display names for each value, and the **Value** column shows the corresponding internal or
"raw" values.

## PARAMETERS

### -Device
Specifies one or more devices returned by the commands `Get-VmsCamera`, `Get-VmsMicrophone`, `Get-VmsSpeaker`, `Get-VmsMetadata`, or `Get-VmsDevice`.

REQUIREMENTS  

- Allowed item types: Camera, Microphone, Speaker, Metadata

```yaml
Type: IConfigurationItem
Parameter Sets: Device
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Id
Specifies the Id of a Camera, Microphone, Speaker, or Metadata.

```yaml
Type: Guid
Parameter Sets: Id
Aliases: Guid

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path
Specifies the XProtect Configuration API item path for the specified device. All devices returned by commands like
`Get-VmsCamera`, or `Get-VmsMicrophone` include a `Path` property like "Camera[f331de86-f4b8-48aa-973a-c52986790b27]" or
"Microphone[2aa20473-b6ee-4455-90be-4cd5d5f9088b]".

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RawValues
Specifies that the raw, internal values of settings should be returned instead of returning the display values seen in Management Client.

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

### -StreamName
Use to limit the stream settings returned to the stream(s) matching the provided stream name. Settings for all available streams are returned by default.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -ValueTypeInfo
Specifies that the hashtable should contain a "ValueTypeInfo" collection for each property, instead of the value of the setting. The "ValueTypeInfo" collections can be used to discover the valid ranges or values for each setting.

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

### VideoOS.Platform.ConfigurationItems.IConfigurationItem

You can pipe any device object to this cmdlet from the `Get-VmsCamera`, `Get-VmsMicrophone`, `Get-VmsSpeaker`,
`Get-VmsMetadata`, or `Get-VmsDevice` commands. Only camera, microphone, speaker, or metadata devices are allowed as
inputs and outputs do not have streams.

### System.Guid

You can pipe any object type having an **Id** property with the `[guid]` id value of an existing camera, microphone,
speaker, or metadata device.

### System.String

You can pipe any object type having a **Path** property with the XProtect Configuration API value of an existing camera,
microphone, speaker, or metadata device.

## OUTPUTS

### MilestonePSTools.DeviceCommands.VmsStreamSettings

## NOTES

This command has the following aliases:

- Get-VmsCameraStreamSetting
- Get-VmsMetadataStreamSetting
- Get-VmsMicrophoneStreamSetting
- Get-VmsSpeakerStreamSetting

## RELATED LINKS

[Set-VmsDeviceStreamSetting](./Set-VmsDeviceStreamSetting.md)

