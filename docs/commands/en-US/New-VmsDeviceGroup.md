---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsDeviceGroup/
schema: 2.0.0
---

# New-VmsDeviceGroup

## SYNOPSIS
Creates a new device group.

## SYNTAX

### ByName
```
New-VmsDeviceGroup [[-ParentGroup] <IConfigurationItem>] [-Name] <String[]> [[-Description] <String>]
 [[-Type] <String>] [<CommonParameters>]
```

### ByPath
```
New-VmsDeviceGroup [-Path] <String[]> [[-Description] <String>] [[-Type] <String>] [<CommonParameters>]
```

## DESCRIPTION
Creates a new device group. Device groups exist for cameras, microphones,
speakers, inputs, outputs, and metadata.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
New-VmsDeviceGroup -Path "/Level 1/Level 2/Level 3"
Get-VmsDeviceGroup -Path "/Level 1/Level 2/Level 3"
```

Creates a three-level deep camera group hierarchy, and then demonstrates how to
retrieve that camera group using the Path parameter.

### Example 2
```powershell
New-VmsDeviceGroup -Path "/Level 1/Level 2/Level 3"
Get-VmsDeviceGroup -Name 'Level 1' | Get-VmsDeviceGroup -Name 'Level 2' | Get-VmsDeviceGroup -Name 'Level 3'
```

Creates a three-level deep camera group hierarchy, and then demonstrates how to
retrieve that camera group by piping the parent group so that the "Name" parameter
will be used to find the group with the matching name within the parent group's
device group folder.

Since no parent group was provided to the first call to Get-VmsDeviceGroup, the
lookup began at (Get-VmsManagementServer).CameraGroupFolder.CameraGroups.

### Example 3
```powershell
New-VmsDeviceGroup -Path "/Level 1/Level 2/Level 3" -Type Microphone
Get-VmsDeviceGroup -Path "/Level 1/Level 2/Level 3" -Type Microphone
```

Creates a three-level deep microphone group hierarchy, and then demonstrates how to
retrieve that microphone group using the Path parameter. Note that the default
device group type is "Camera" so when working with other device types you will
need to specify the device group type.

### Example 4
```powershell
New-VmsDeviceGroup -Name "Level 1" | New-VmsDeviceGroup -Name "Level 2" | New-VmsDeviceGroup -Name "Level 3"
```

Creates a three-level deep camera group hierarchy by creating the first level, then
piping it to `New-VmsDeviceGroup` to create a child group, and piping that child
group to `New-VmsDeviceGroup` again to create the "Level 3" camera group which
has the root-level camera group "Level 1" as a grand-parent.

## PARAMETERS

### -Description
Specifies an optional description for the device group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies a name for the new device group.

```yaml
Type: String[]
Parameter Sets: ByName
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParentGroup
Specifies the parent device group as is returned from Get-VmsDeviceGroup.

REQUIREMENTS  

- Allowed item types: CameraGroup, MicrophoneGroup, SpeakerGroup, MetadataGroup, InputEventGroup, OutputGroup

```yaml
Type: IConfigurationItem
Parameter Sets: ByName
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Specifies a full unix-style path to the desired device group. See the examples
for reference.

```yaml
Type: String[]
Parameter Sets: ByPath
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Specifies the type of device group to return. The default is "Camera".

```yaml
Type: String
Parameter Sets: (All)
Aliases: DeviceCategory
Accepted values: Camera, Microphone, Speaker, Input, Output, Metadata

Required: False
Position: 4
Default value: Camera
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.IConfigurationItem

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.IConfigurationItem
## NOTES

## RELATED LINKS
