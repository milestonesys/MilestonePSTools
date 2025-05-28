---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-VmsDeviceGroupMember/
schema: 2.0.0
---

# Add-VmsDeviceGroupMember

## SYNOPSIS
Add one or more devices to a device group.

## SYNTAX

### ByObject
```
Add-VmsDeviceGroupMember [-Group <IConfigurationItem>] [-Device] <IConfigurationItem[]> [<CommonParameters>]
```

### ById
```
Add-VmsDeviceGroupMember [-Group <IConfigurationItem>] [-DeviceId] <Guid[]> [<CommonParameters>]
```

## DESCRIPTION
Add one or more devices to a device group by ID, or using the objects returned by cmdlets like Get-VmsCamera.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
$cameras = Get-VmsHardware | Get-VmsCamera | Where-Object Name -like '*West*'
Get-VmsDeviceGroup 'Parking West' | Add-VmsDeviceGroupMember -Device $cameras
```

Adds all enabled cameras with the word "West" in the camera name to the
"Parking West" camera group.

### Example 2
```powershell
Get-VmsDeviceGroup -Type Metadata -Name 'All Metadata' | Add-VmsDeviceGroupMember -Device (Get-VmsHardware | Get-VmsMetadata -EnableFilter All)
```

Adds all metadata to the "All Metadata" device group.

## PARAMETERS

### -Device
Specifies one or more devices of the same type. Supported devices are cameras, microphones, speakers, metadata, inputs, and outputs.

REQUIREMENTS  

- Allowed item types: Camera, Microphone, Speaker, Metadata, InputEvent, Output

```yaml
Type: IConfigurationItem[]
Parameter Sets: ByObject
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceId
Specifies the ID of one or more devices.

```yaml
Type: Guid[]
Parameter Sets: ById
Aliases: Id

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Group
Specifies a device group object returned by Get-VmsDeviceGroup.

REQUIREMENTS  

- Allowed item types: CameraGroup, MicrophoneGroup, SpeakerGroup, MetadataGroup, InputEventGroup, OutputGroup

```yaml
Type: IConfigurationItem
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.IConfigurationItem

## OUTPUTS

### None
## NOTES

## RELATED LINKS
