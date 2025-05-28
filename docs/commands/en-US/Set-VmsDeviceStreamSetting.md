---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsDeviceStreamSetting/
schema: 2.0.0
---

# Set-VmsDeviceStreamSetting

## SYNOPSIS
Sets one or more stream settings for any device type.

## SYNTAX

### Device (Default)
```
Set-VmsDeviceStreamSetting [-Device] <IConfigurationItem> [-StreamName <String>] -Settings <IDictionary>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Id
```
Set-VmsDeviceStreamSetting [-Id] <Guid> [-StreamName <String>] -Settings <IDictionary> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Path
```
Set-VmsDeviceStreamSetting [-Path] <String> [-StreamName <String>] -Settings <IDictionary> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsDeviceStreamSetting` cmdlet is used to change one or more stream settings at a time using
a hashtable with keys matching existing stream setting property names. This command may be used on any
streaming child device of a **Hardware** object including cameras, microphones, speakers, and metadata.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1: Change the resolution for a camera
```powershell
# Get one random enabled camera
$camera = Get-VmsCamera | Get-Random

# Change the resolution for Video stream 1 to 1920x1080
$camera | Set-VmsDeviceStreamSetting -StreamName 'Video stream 1' -Settings @{ Resolution = '1920x1080' } -WhatIf
```

```Output
What if: Performing the operation "Change stream:0.0.0/Resolution/2b25c3c5-35ba-4ec1-a748-f225732161ed from 1280x720 to 1920x1080" on target "Doorbell".
```

This example demonstrates one way to change the **Resolution** setting for a video stream named "Video stream 1". Since
the `-WhatIf` switch parameter is present, the setting will not be modified.

### Example 2: Change the codec for a camera
```powershell
# Get one random enabled camera
$camera = Get-VmsCamera | Get-Random

# Get the settings for "Video stream 01"
$settings = $camera | Get-VmsDeviceStreamSetting -StreamName *1

$settings.Settings.Codec = 'H.264 Main Profile'

# Pipe in the modified stream settings
$settings | Set-VmsDeviceStreamSetting -WhatIf
```

```Output
What if: Performing the operation "Change stream:0.0.0/Codec/78622c19-58ae-40d4-8eea-17351f4273b6 from 6 to 4" on target "Doorbell".
```

This example demonstrates another way to change a setting for a video stream. In this case the value for **Codec** is
modified on the stream settings returned by `Get-VmsDeviceStreamSetting`, and the modified object is piped to
`Set-VmsDeviceStreamSetting`. Since the `-WhatIf` switch parameter is present, the setting will not be modified.

Note that the required _internal value_ of the **Codec** property is automatically resolved to "4" since "H.264 Main Profile"
is the _display value_ for that codec option.

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

### -Settings
Accepts a hashtable where keys match stream setting keys for the specified stream(s) on the provided device.

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

### -StreamName
Limit the stream setting changes to streams matching the provided stream name. This parameter is required when the device has more than one stream, and it supports the use of wildcards.

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

### System.Guid

### System.Collections.IDictionary

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
