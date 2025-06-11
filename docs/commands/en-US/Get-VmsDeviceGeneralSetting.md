---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsDeviceGeneralSetting/
schema: 2.0.0
---

# Get-VmsDeviceGeneralSetting

## SYNOPSIS
Gets the general settings for one or more devices.

## SYNTAX

### Device (Default)
```
Get-VmsDeviceGeneralSetting [-Device] <IConfigurationItem> [-RawValues] [-ValueTypeInfo] [<CommonParameters>]
```

### Id
```
Get-VmsDeviceGeneralSetting [-Id] <Guid> [-RawValues] [-ValueTypeInfo] [<CommonParameters>]
```

### Path
```
Get-VmsDeviceGeneralSetting [-Path] <String> [-RawValues] [-ValueTypeInfo] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet returns a hashtable with all the general settings available for a
device, including read-only settings and settings usually hidden from the
Management Client user interface.

General settings often include properties like "Rotation", "Saturation",
and "Brightness", which usually apply to all streams available from the device.

Each device model will have a different set of general settings, and some
devices may not have any general settings at all.

The values returned by this cmdlet are the "display values" you should see in
the Management Client. To see the raw, internal values used by the MIP SDK, you
may use the "-RawValues" switch.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1 - Explore general settings for a camera
```powershell
Connect-Vms -ShowDialog -AcceptEula
$camera = Select-Camera -SingleSelect -Title 'Select a camera (double-click)'
$camera | Get-VmsDeviceGeneralSetting

<# OUTPUT (display values)
Name                           Value
----                           -----
RecorderMode                   Disabled
MulticastVideoPort             0
RecorderRetentionTime          336
Saturation                     50
RecorderAudioEnabled           No
Sharpness                      50
Brightness                     50
EdgeStorageRecording           Continuous
EdgeStorageStreamIndex         0
Rotation                       0
MulticastAddress               239.244.177.82
RecorderStreamIndex            1
OSDDateTime                    Disabled
RecorderPostTriggerTime        0
MulticastTTL                   5
EdgeStorageEnabled             false
BlackAndWhiteMode              Color
MulticastForceSSM              No
WhiteBalance                   Automatic
RecorderPreTriggerTime         0
#>

$camera | Get-VmsDeviceGeneralSetting -RawValues

<# OUTPUT (raw values)
Name                           Value
----                           -----
RecorderMode                   Disabled
MulticastVideoPort             0
RecorderRetentionTime          336
Saturation                     50
RecorderAudioEnabled           no
Sharpness                      50
Brightness                     50
EdgeStorageRecording           Continuous
EdgeStorageStreamIndex         0
Rotation                       0
MulticastAddress               239.244.177.82
RecorderStreamIndex            1
OSDDateTime                    Disabled
RecorderPostTriggerTime        0
MulticastTTL                   5
EdgeStorageEnabled             False
BlackAndWhiteMode              Yes
MulticastForceSSM              no
WhiteBalance                   Automatic
RecorderPreTriggerTime         0
#>

($camera | Get-VmsDeviceGeneralSetting -ValueTypeInfo).BlackAndWhiteMode

<# OUTPUT
TranslationId                        Name          Value
-------------                        ----          -----
d65be37a-9416-4bbf-8ed3-36ebd12cd837 Color         Yes
f7729675-9e20-4593-9611-f53c11c6fdd4 Black & White No
#>
```

In this example we show how to login, select a camera using an interactive
camera selection dialog, and then display the general settings for the camera
using the default "display values". Then we show how the same settings appear
when using the raw values. For example, the display value for BlackAndWhiteMode
is "Color", and the raw value is "Yes".

For reference, the ValueTypeInfo collection for the BlackAndWhiteMode setting
is displayed. You can see how the ValueTypeInfo collection maps the raw value
"Yes" to the display value "Color".

### Example 2 - Get all general settings for Hardware

```powershell
$hardware = Get-VmsHardware | Select-Object -First 1
$hardware | Get-VmsHardwareGeneralSetting
```

In this example, one hardware object is stored in the `$hardware` variable, and then `$hardware` is piped to
`Get-VmsHardwareGeneralSetting` which returns all general setting keys and values in a `hashtable`.

## PARAMETERS

### -Device
Specifies one or more devices returned by the commands `Get-VmsCamera`, `Get-VmsMicrophone`, `Get-VmsSpeaker`, `Get-VmsMetadata`,
`Get-VmsInput`, `Get-VmsOutput`, `Get-VmsDevice`, or `Get-VmsHardware`.

REQUIREMENTS  

- Allowed item types: Camera, Microphone, Speaker, Metadata, InputEvent, Output, Hardware

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
Specifies the Id of a Camera, Microphone, Speaker, Metadata, Input, Output or Hardware device.

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
`Get-VmsMetadata`, `Get-VmsInput`, `Get-VmsOutput`, or `Get-VmsDevice` commands.

## OUTPUTS

### Hashtable

This cmdlet returns a hashtable where the keys match general setting property names, and the values are
either the display values (e.g. the values shown in Management Client), the "raw values" (e.g. the internal
values recognized by the VMS), or the ValueTypeInfo collections which describe the allowed values for each
setting.

## NOTES

This command has the following aliases:

- Get-VmsCameraGeneralSetting
- Get-VmsHardwareGeneralSetting
- Get-VmsInputGeneralSetting
- Get-VmsMetadataGeneralSetting
- Get-VmsMicrophoneGeneralSetting
- Get-VmsOutputGeneralSetting
- Get-VmsSpeakerGeneralSetting

## RELATED LINKS

[Set-VmsDeviceGeneralSetting](./Set-VmsDeviceGeneralSetting.md)
