---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsDeviceGeneralSetting/
schema: 2.0.0
---

# Set-VmsDeviceGeneralSetting

## SYNOPSIS
Sets one or more general settings for any device type.

## SYNTAX

### Device (Default)
```
Set-VmsDeviceGeneralSetting [-Device] <IConfigurationItem> -Settings <IDictionary> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Id
```
Set-VmsDeviceGeneralSetting [-Id] <Guid> -Settings <IDictionary> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Path
```
Set-VmsDeviceGeneralSetting [-Path] <String> -Settings <IDictionary> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsDeviceGeneralSetting` cmdlet is used to change one or more general settings at a time using
a hashtable with keys matching existing general setting property names. This command may be used on any
child device of a **Hardware** object including cameras, microphones, speakers, metadata, inputs, and
outputs, as well as the parent hardware object.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1 - Update general settings for a Camera
```powershell
Connect-Vms -ShowDialog -AcceptEula
$camera = Select-Camera -SingleSelect -Title 'Select a camera (double-click)'
$settings = @{
    BlackAndWhiteMode = 'Yes'
}
$camera | Set-VmsDeviceGeneralSetting -Settings $settings -Verbose

<# OUTPUT
VERBOSE: Performing the operation "Changing BlackAndWhiteMode from No to Yes" on target "Elevator".
VERBOSE: Performing the operation "Save changes" on target "Elevator".
#>

$camera = Select-Camera -SingleSelect -Title 'Select a camera (double-click)'
$camera | Set-VmsDeviceGeneralSetting -Settings $settings -Verbose

<# OUTPUT (no BlackAndWhiteMode setting available)
WARNING: A general setting named 'BlackAndWhiteMode' was not found on Garage.
#>
```

In this example we login to the Management Server, present a camera selection
dialog, and then attempt to update the BlackAndWhiteMode value to "Yes" which,
perhaps counter-intuitively, represents "Color" based on the ValueTypeInfo for
the camera used for testing.

We then present another camera selection dialog, where you can choose a
different camera lacking a "BlackAndWhiteMode" general setting, and demonstrate
the warning message you can expect when attempting to update general settings
that are not present on a camera.

### Example 2 - Update general settings for hardware

```powershell
$hardware = Get-VmsHardware | Out-GridView -OutputMode Single
$hardware | Set-VmsHardwareGeneralSetting -Setting @{
    FPS            = 30
    VideoCodec     = 'H264'
    VideoH264Files = '_1920x1080_30_5_shoes_short'
}
```

This example demonstrates how to configure a StableFPS hardware device to use the default H.264 video file at 30 frames
per second.

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
Specifies the Id of a Camera, Microphone, Speaker, Metadata, Input, Output, or Hardware device.

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

### -Settings
Accepts a hashtable of settings used to update the general settings for a given
device.

```yaml
Type: IDictionary
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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

### System.Collections.Hashtable

You can pipe any object type having a **Settings** hashtable property with one or more key/value pairs.

## OUTPUTS

### None

## NOTES

This command has the following aliases:

- Set-VmsCameraGeneralSetting
- Set-VmsHardwareGeneralSetting
- Set-VmsInputGeneralSetting
- Set-VmsMetadataGeneralSetting
- Set-VmsMicrophoneGeneralSetting
- Set-VmsOutputGeneralSetting
- Set-VmsSpeakerGeneralSetting

## RELATED LINKS

[Get-VmsDeviceGeneralSetting](./Get-VmsDeviceGeneralSetting.md)
