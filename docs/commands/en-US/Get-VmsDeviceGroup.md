---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsDeviceGroup/
schema: 2.0.0
---

# Get-VmsDeviceGroup

## SYNOPSIS
Gets the device groups matching the specified criteria.

## SYNTAX

### ByName (Default)
```
Get-VmsDeviceGroup [-ParentGroup <IConfigurationItem>] [[-Name] <String>] [[-Type] <String>] [-Recurse]
 [<CommonParameters>]
```

### ByPath
```
Get-VmsDeviceGroup [-Path] <String[]> [[-Type] <String>] [-Recurse] [<CommonParameters>]
```

## DESCRIPTION
Gets the device groups matching the specified criteria. This cmdlet can return
device groups of the following types: Camera, Microphone, Speaker, Metadata,
Input and Output.

Device groups are hierarchical and can each have any number of siblings and
children. The MilestonePSTools module adds a unix-style path feature where the
device group "path" can be specified like "/Top-level group/subgroup/subgroup".

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

## PARAMETERS

### -Name
Specifies the name of a device group.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParentGroup
Specifies the parent device group. Only children of this group will be returned.

REQUIREMENTS  

- Allowed item types: CameraGroup, MicrophoneGroup, SpeakerGroup, MetadataGroup, InputEventGroup, OutputGroup

```yaml
Type: IConfigurationItem
Parameter Sets: ByName
Aliases:

Required: False
Position: Named
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
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recurse
Specifies that the matching device group, and all child device groups should be
returned recursively.

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

### -Type
Specifies the type of device group to return. The default is "Camera".

```yaml
Type: String
Parameter Sets: (All)
Aliases: DeviceCategory
Accepted values: Camera, Microphone, Speaker, Input, Output, Metadata

Required: False
Position: 2
Default value: Camera
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
