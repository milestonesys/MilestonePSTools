---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-Bookmark/
schema: 2.0.0
---

# Remove-Bookmark

## SYNOPSIS

Removes / deletes a bookmark

## SYNTAX

### FromBookmark
```
Remove-Bookmark -Bookmark <Bookmark> [<CommonParameters>]
```

### FromId
```
Remove-Bookmark -BookmarkId <Guid> [<CommonParameters>]
```

## DESCRIPTION

Takes a bookmark, or a bookmark ID from the pipeline or parameters, and deletes it.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-Bookmark -DeviceId $id | Remove-Bookmark
```

Remove all bookmarks for the last hour of video for device with ID $id

### EXAMPLE 2

```powershell
Get-Bookmark -Timestamp '2019-06-04 14:00:00' -Minutes 120 | Remove-Bookmark
```

Removes all bookmarks for any device where the bookmark time is between 2PM and 4PM local time on the 4th of June.

## PARAMETERS

### -Bookmark

Specifies the bookmark object to be deleted.

```yaml
Type: Bookmark
Parameter Sets: FromBookmark
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -BookmarkId

Specifies the ID of the bookmark object to be deleted.

```yaml
Type: Guid
Parameter Sets: FromId
Aliases:

Required: True
Position: Named
Default value: 00000000-0000-0000-0000-000000000000
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Common.Proxy.Server.WCF.Bookmark

Specifies the bookmark object to be deleted.

### System.Guid

Specifies the ID of the bookmark object to be deleted.

## OUTPUTS

## NOTES

## RELATED LINKS
