---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Resolve-VmsDeviceGroupPath/
schema: 2.0.0
---

# Resolve-VmsDeviceGroupPath

## SYNOPSIS

Returns a string representing the device group path in a way MilestonePSTools understands.

## SYNTAX

```
Resolve-VmsDeviceGroupPath [-Group] <IConfigurationItem> [-NoTypePrefix] [<CommonParameters>]
```

## DESCRIPTION

The *-VmsDeviceGroup* commands accept device groups in a unix file path format like
"/first level/second level/third level" where each name separated by a slash is a child group
of the group preceeding it.

The Get-VmsDeviceGroup command returns an object representing a single device group and it is not
immediately obvious what the hierarchy of the group is when inspecting the single group object.
To remedy this, Resolve-VmsDeviceGroupPath will recursively look at the ParentPath property of
the group and enumerate upward through the hierarchy until reaching the root of the device
group tree.
The names of all the parent groups along the path will be returned along with the
name of the group.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsDeviceGroup -Recurse | Resolve-VmsDeviceGroupPath
```

Returns all camera device group paths, recursively, as strings.

## PARAMETERS

### -Group
A Camera, Microphone, Speaker, Input, Output, or Metadata group. Consider
using Get-VmsDeviceGroup to select the desired group object.

REQUIREMENTS  

- Allowed item types: CameraGroup, MicrophoneGroup, SpeakerGroup, MetadataGroup, InputEventGroup, OutputGroup

```yaml
Type: IConfigurationItem
Parameter Sets: (All)
Aliases: DeviceGroup

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -NoTypePrefix
Omit device group type prefix. For example "/CameraGroupFolder".

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

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
