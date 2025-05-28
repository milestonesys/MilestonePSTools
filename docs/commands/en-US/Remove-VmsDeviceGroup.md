---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsDeviceGroup/
schema: 2.0.0
---

# Remove-VmsDeviceGroup

## SYNOPSIS
Deletes a device group and the underlying hierarchy of devices and subgroups.

## SYNTAX

```
Remove-VmsDeviceGroup [[-Group] <IConfigurationItem[]>] [-Recurse] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Deletes a device group and the underlying hierarchy of devices and subgroups.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsDeviceGroup -Name TestGroup | Remove-VmsDeviceGroup -Recurse
```

Gets the root-level camera group "TestGroup" if it exists, and removes the group
and all child groups and members recursively.

## PARAMETERS

### -Group
Specifies one or more device groups as is returned by Get-VmsDeviceGroup.

REQUIREMENTS  

- Allowed item types: CameraGroup, MicrophoneGroup, MetadataGroup, SpeakerGroup, InputEventGroup, OutputGroup

```yaml
Type: IConfigurationItem[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Recurse
Specifies that the device group should be removed even if it contains device members
or subgroups.

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

### VideoOS.Platform.ConfigurationItems.IConfigurationItem[]

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
