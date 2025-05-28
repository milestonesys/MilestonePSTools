---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Find-VmsVideoOSItem/
schema: 2.0.0
---

# Find-VmsVideoOSItem

## SYNOPSIS
Find items in the system configuration based on the provided search text and optional filters.

## SYNTAX

```
Find-VmsVideoOSItem [-SearchText] <String[]> [-MaxCount <Int32>] [-MaxSeconds <Int32>] [-Kind <Guid>]
 [-FolderType <FolderType>] [<CommonParameters>]
```

## DESCRIPTION
Find items in the system configuration based on the provided search text and
optional filters. In a large, multi-site environment, it can be faster to find
known items by name.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Find-VmsVideoOSItem -SearchText 'Playground' -Kind Camera -FolderType No
```

Finds all camera items with the case-insensitive string "Playground" in the name.
By specifying `-FolderType -No`, only "leaf" items are returned and camera groups
will not be included.

## PARAMETERS

### -FolderType
Specifies an optional FolderType value of No, SystemDefined, or UserDefined.
If you are searching for camera, or hardware objects, you should set FolderType
to "No" unless you also want to receive camera groups and hardware folders.

```yaml
Type: FolderType
Parameter Sets: (All)
Aliases:
Accepted values: No, SystemDefined, UserDefined

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Kind
Specifies the ID or name of an item "Kind". For a list of supported values, run
`[VideoOS.Platform.Kind] | Get-Member -Static -MemberType Property | Where-Object Definition -match 'static guid'`

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxCount
Specifies the maximum number of search results to return. A lower number can
result in faster execution.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxSeconds
Specifies the maximum number of seconds before the search should be stopped, even
if no items have been found yet.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchText
Specifies one or more values to search for. Item names and their property keys and
values will be searched. Note that this means a search for "EdgeSupported" will
return any item with the EdgeSupported property, whether that property value is
"Yes", or "No".

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

### VideoOS.Platform.Item

## NOTES

## RELATED LINKS
