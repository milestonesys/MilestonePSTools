---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsParentItem/
schema: 2.0.0
---

# Get-VmsParentItem

## SYNOPSIS
Gets the parent item associated with the ParentItemPath property of an item.

## SYNTAX

### InputObject (Default)
```
Get-VmsParentItem -InputObject <IConfigurationItem[]> [<CommonParameters>]
```

### ParentItemPath
```
Get-VmsParentItem -ParentItemPath <String[]> [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsParentItem` cmdlet gets the parent item associated with the ParentItemPath property of an item. For example
the parent item for a Camera, Microphone, Speaker, Metadata, Input, or Output object is a Hardware object. All of these
items have a `ParentItemPath` property like "Hardware[c3788c84-ba55-443d-bb58-19f862489e11]" which is a Config API path
indicating the item type "Hardware" and the ID "c3788c84-ba55-443d-bb58-19f862489e11".

This cmdlet makes it easy to retrieve the parent object without the need to parse the `ParentItemPath` property. It will
also work on other objects like Storage or Archive configurations. For example, the parent item for a `Storage` object
is a `RecordingServer`, and the parent item for an `ArchiveStorage` object is the parent `Storage` object.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
$camera = Get-VmsCamera | Get-Random
$hardware = $camera | Get-VmsParentItem
$recorder = $hardware | Get-VmsParentItem
[pscustomobject]@{
    Camera   = $camera
    Hardware = $hardware
    Recorder = $recorder
}
```

This example gets a random camera, and then gets the parent `Hardware` object, and the hardware object's parent
`Recorder` object.

## PARAMETERS

### -InputObject
Specifies any Configuration API object with either a `ParentItemPath` or `ParentPath` property.

```yaml
Type: IConfigurationItem[]
Parameter Sets: InputObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ParentItemPath
Specifies the `ParentItemPath` or `ParentPath` property for a Configuration API object.

```yaml
Type: String[]
Parameter Sets: ParentItemPath
Aliases: ParentPath

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.IConfigurationItem[]

### System.String[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.IConfigurationItem

## NOTES

## RELATED LINKS
