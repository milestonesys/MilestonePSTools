---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsDeviceGroupMember/
schema: 2.0.0
---

# Remove-VmsDeviceGroupMember

## SYNOPSIS
Removes one or more device group members from the specifies device group.

## SYNTAX

### ByObject
```
Remove-VmsDeviceGroupMember -Group <IConfigurationItem> [-Device] <IConfigurationItem[]> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### ById
```
Remove-VmsDeviceGroupMember -Group <IConfigurationItem> [-DeviceId] <Guid[]> [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Removes one or more device group members from the specifies device group.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsDeviceGroup -Recurse | Remove-VmsDeviceGroupMember -DeviceId '8a4e127d-5a5c-4163-a494-721754864e31' -ErrorAction SilentlyContinue
```

Removes the camera with ID "8a4e127d-5a5c-4163-a494-721754864e31" from all camera
groups it happens to be a member of. The "ErrorAction" parameter is set to
"SilentlyContinue" to ensure that no errors are emitted to the terminal when the
camera is not a member of the camera group when we try to remove it.

## PARAMETERS

### -Device
Specifies the device object as is returned by Get-VmsCamera or Get-VmsMicrophone for example.

REQUIREMENTS  

- Allowed item types: Camera, Microphone, Metadata, Speaker, InputEvent, Output

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
Specifies the ID of the device to be removed.

```yaml
Type: Guid[]
Parameter Sets: ById
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Group
Specifies the device group from which the member(s) should be removed. The value
for this parameter is returned from Get-VmsDeviceGroup.

REQUIREMENTS  

- Allowed item types: CameraGroup, MicrophoneGroup, MetadataGroup, SpeakerGroup, InputEventGroup, OutputGroup

```yaml
Type: IConfigurationItem
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
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

## OUTPUTS

### None
## NOTES

## RELATED LINKS
