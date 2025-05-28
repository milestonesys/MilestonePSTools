---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Update-Bookmark/
schema: 2.0.0
---

# Update-Bookmark

## SYNOPSIS

Updates the properties of a bookmark

## SYNTAX

```
Update-Bookmark -Bookmark <Bookmark> [<CommonParameters>]
```

## DESCRIPTION

Updates a bookmark in the VMS by pushing changes to the bookmark object up to the Management Server.

The expected workflow is that a bookmark is retrieved using Get-Bookmark.
Then properties of the local bookmark object are changed as desired.
Finally the modified local bookmark object is used to update the record on the Management Server by piping it to this cmdlet.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-Bookmark -Timestamp '2019-06-04 14:00:00' -Minutes 120 | ForEach-Object { $_.Description = 'Testing'; $_ | Update-Bookmark }
```

Gets all bookmarks for any device where the bookmark time is between 2PM and 4PM local time on the 4th of June, changes the Description to 'Testing', and sends the updated bookmark to the Management Server.

## PARAMETERS

### -Bookmark

Specifies the bookmark object to be updated.

```yaml
Type: Bookmark
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Common.Proxy.Server.WCF.Bookmark

Specifies the bookmark object to be updated.

## OUTPUTS

## NOTES

## RELATED LINKS
