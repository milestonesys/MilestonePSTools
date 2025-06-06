---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsDeviceGroup/
schema: 2.0.0
---

# Set-VmsDeviceGroup

## SYNOPSIS
Sets the name or description property of the specified device group.

## SYNTAX

```
Set-VmsDeviceGroup [-Group] <IConfigurationItem> [[-Name] <String>] [[-Description] <String>] [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sets the name or description property of the specified device group. This cmdlet
would be used primary to rename a device group or to modify the description of
the group.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
$group = Get-VmsDeviceGroup 'Camera Models'
$params = @{
    Name        = "Cameras by Model"
    Description = "Auto-generated device group with cameras organized by model."
}
$group | Set-VmsDeviceGroup @params -PassThru

<# RESULT

DisplayName      ItemCategory Path                                              ParentPath
-----------      ------------ ----                                              ----------
Cameras by Model Item         CameraGroup[807dfed2-57a5-4416-9be9-315eb04e0f6a] /CameraGroupFolder

#>
```

Renames the root camera group "Camera Models" to "Cameras by Model" and updates
the description, passing the modified device group to the terminal in the end.

## PARAMETERS

### -Description
Specifies an optional device group description.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Group
Specifies the device group. The value for this parameter is returned from
Get-VmsDeviceGroup.

REQUIREMENTS  

- Allowed item types: CameraGroup, MicrophoneGroup, MetadataGroup, SpeakerGroup, InputEventGroup, OutputGroup

```yaml
Type: IConfigurationItem
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
Specifies a new name for the provided device group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Specifies that the modified device group should be returned after applying changes.

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

### VideoOS.Platform.ConfigurationItems.IConfigurationItem

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.IConfigurationItem

## NOTES

## RELATED LINKS
