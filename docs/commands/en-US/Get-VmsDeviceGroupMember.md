---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsDeviceGroupMember/
schema: 2.0.0
---

# Get-VmsDeviceGroupMember

## SYNOPSIS
Gets all member devices of the specified device group.

## SYNTAX

```
Get-VmsDeviceGroupMember [[-Group] <IConfigurationItem>] [[-EnableFilter] <EnableFilter>] [<CommonParameters>]
```

## DESCRIPTION
Gets all member devices of the specified device group.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsDeviceGroup -Recurse | Get-VmsDeviceGroupMember
```

Returns a list of all cameras in all camera groups, recursively. Note that since
a camera may be in more than one device group, this will potentially return
multiple instances of the same camera.

## PARAMETERS

### -EnableFilter
Specifies that the allowed enabled-state for devices returned. By default, only
enabled devices are returned.

```yaml
Type: EnableFilter
Parameter Sets: (All)
Aliases:
Accepted values: All, Enabled, Disabled

Required: False
Position: 1
Default value: Enabled
Accept pipeline input: False
Accept wildcard characters: False
```

### -Group
Specifies the device group from which to return member devices.

REQUIREMENTS  

- Allowed item types: CameraGroup, MicrophoneGroup, MetadataGroup, SpeakerGroup, InputEventGroup, OutputGroup

```yaml
Type: IConfigurationItem
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
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
