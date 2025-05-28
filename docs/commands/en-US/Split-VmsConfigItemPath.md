---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Split-VmsConfigItemPath/
schema: 2.0.0
---

# Split-VmsConfigItemPath

## SYNOPSIS
Returns the specified part of the Milestone Configuration API path.

## SYNTAX

### Id (Default)
```
Split-VmsConfigItemPath [-Path] <String[]> [-Id] [<CommonParameters>]
```

### ParentItemType
```
Split-VmsConfigItemPath [-Path] <String[]> [-ParentItemType] [<CommonParameters>]
```

### ItemType
```
Split-VmsConfigItemPath [-Path] <String[]> [-ItemType] [<CommonParameters>]
```

## DESCRIPTION
The `Split-VmsConfigItemPath` cmdlet returns the specified part of the provided Milestone Configuration API path. These
paths usually look like "Hardware[7abcfcdc-7d6f-4a1a-b7a3-f77607806169]" or "CameraGroup[81258601-71ef-41e7-bd59-41946e16fc5a]/CameraGroupFolder"
where "Hardware" and "CameraGroupFolder" are the ItemType values, and in the case of the second example, "CameraGroup"
is the ParentItemType.

REQUIREMENTS  

- None specified

## EXAMPLES

### Example 1
```powershell
Get-VmsHardware | Get-Random | Split-VmsConfigItemPath
```

Returns the Id of a given Hardware device based on the `Path` property of the hardware object.

### Example 2
```powershell
Get-VmsHardware | Get-Random | Split-VmsConfigItemPath -ItemType
```

Returns the ItemType value "Hardware".

## PARAMETERS

### -Id
Specifies that the value returned from the configuration item path should be the Id, if present.

```yaml
Type: SwitchParameter
Parameter Sets: Id
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ItemType
Specifies that the value returned from the configuration item path should be the ItemType.

```yaml
Type: SwitchParameter
Parameter Sets: ItemType
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParentItemType
Specifies that the value returned from the configuration item path should be the ParentItemType, if present. This applies
typically only to "Folder" items as the ParentItemType isn't described in the configuration item path for a normal "item".

```yaml
Type: SwitchParameter
Parameter Sets: ParentItemType
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Specifies the Milestone XProtect Configuration API path from which the specified part should be returned.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
