---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-ConfigurationItem/
schema: 2.0.0
---

# Get-ConfigurationItem

## SYNOPSIS

Gets a ConfigurationItem object

## SYNTAX

```
Get-ConfigurationItem [-ConfigurationItem <ConfigurationItem>] [-ItemType <String>] [-Id <Guid>]
 [[-Path] <String>] [-ChildItems] [-Parent] [-ParentItem] [-Recurse] [-Sort] [<CommonParameters>]
```

## DESCRIPTION

Uses the Configuration API to access configuration items.
Useful for navigating the configuration of the VMS without the need to understand the individual object types like cameras, servers, and users.

Each ConfigurationItem may have child items, methods that could be invoked, or properties that can be read and/or modified.
Use Set-ConfigurationItem to save changes made to a ConfigurationItem object.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
$ms = Get-ConfigurationItem -Path "/"
$nameProperty = $ms.Properties | Where-Object Key -eq "Name"
$nameProperty.Value = "New Name"
$ms | Set-ConfigurationItem
```

Changes the Name property of the Management Server

## PARAMETERS

### -ChildItems

Get all child items for the given ConfigurationItem, Path, or ItemType and ID pair

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigurationItem

Specifies a source ConfigurationItem for retrieving a Child or Parent ConfigurationItem

```yaml
Type: ConfigurationItem
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Id

Specifies a Guid identifier to use for constructing a path in the form of ItemType\[Id\]

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 00000000-0000-0000-0000-000000000000
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ItemType

Specifies an item type such as Camera, Hardware, RecordingServer, to use for constructing a path in the form of ItemType\[Id\]

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Parent

Get the immediate parent of a given ConfigurationItem, Path, or ItemType and ID pair

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParentItem

Get the first parent of a given ConfigurationItem, Path, or ItemType and ID pair where the ItemCategory is "Item"

This is mostly used when navigating up from a Camera device to the parent Hardware device, or Hardware to Recording Server

The -Parent switch will provide the immediate parent which might be a Folder rather than an actual recognizable device

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Specifies the Configuration API path string for a given item if already known.

These are typically in the form of Camera\[GUID\] but you can always start crawling the configuration from the top starting at "/" which specifies the Management Server itself.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Recurse

Return the desired ConfigurationItem and all child items recursively.

Note: This can take a very long time to return a result depending on the provided Path and size of the VMS.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Sort

Specifies that device child items should be sorted by channel number after receiving the randomly-ordered list of devices from the Milestone Configuration API.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.ConfigurationApi.ClientService.ConfigurationItem

Specifies a source ConfigurationItem for retrieving a Child or Parent ConfigurationItem

### System.String

Specifies an item type such as Camera, Hardware, RecordingServer, to use for constructing a path in the form of ItemType\[Id\]

### System.Guid

Specifies a Guid identifier to use for constructing a path in the form of ItemType\[Id\]

### System.String

Specifies the Configuration API path string for a given item if already known.

These are typically in the form of Camera\[GUID\] but you can always start crawling the configuration from the top starting at "/" which specifies the Management Server itself.

## OUTPUTS

### VideoOS.ConfigurationApi.ClientService.ConfigurationItem

## NOTES

## RELATED LINKS

[MIP SDK Docs - Configuration API](https://doc.developer.milestonesys.com/html/index.html?base=gettingstarted/intro_configurationapi.html&tree=tree_4.html)

