---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Select-Camera/
schema: 2.0.0
---

# Select-Camera

## SYNOPSIS

Offers a UI dialog for selecting items, similar to the item selection interface in Management Client.

## SYNTAX

```
Select-Camera [[-Title] <String>] [-SingleSelect] [-AllowFolders] [-AllowServers] [-RemoveDuplicates]
 [-OutputAsItem] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet implements the VideoOS.Platform.UI.ItemPickerUserControl in a custom form to allow the user to
select one or more items of any kind using a friendly and customizable user interface.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires an interactive PowerShell session.

## EXAMPLES

### EXAMPLE 1

```powershell
Select-Camera -AllowFolders -AllowServers -RemoveDuplicates
```

Launch the Item Picker and allow the user to add servers or whole groups/folders.
The output will be de-duplicated in the
event the user-defined groups have the same camera(s) present in more than one child folder.
The objects returned will be
the same kind of object returned by the Get-VmsCamera cmdlet.

### EXAMPLE 2

```powershell
Select-Camera -OutputAsItem | ForEach-Object { Get-Snapshot -CameraId $_.FQID.ObjectId -Live }
```

Launch the Item Picker and use the resulting Item.FQID.ObjectId properties of the camera(s) to get a live snapshot from
the Get-Snapshot cmdlet.

## PARAMETERS

### -AllowFolders

Device groups are considered folders and are not selectable by default.
To allow for selecting many items with one click,
include this parameter.
Consider using this with the FlattenOutput switch unless you specifically need to select a folder
item instead of it's child items.

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

### -AllowServers

Supply this switch to enable selection of servers.
You might choose to do this if you want to select Recording Servers,
or you want to select all child items, such as cameras, from a server.
Consider using this with the FlattenOutput switch
unless you specifically need to select a server item instead of it's child items.

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

### -OutputAsItem

Output cameras as VideoOS.Platform.Item objects instead of converting them to Configuration API Camera objects.
Depending
on your needs, it may be more performant to use OutputAsItem.
For example, if you are using a cmdlet like Get-Snapshot, you
can extract the $item.FQID.ObjectId and provide that Guid in the CameraId parameter to avoid an unnecessary conversion
between Item, ConfigurationItem, and back again.

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

### -RemoveDuplicates

Automatically remove duplicate cameras from the output before outputing them.
Useful when you select a folder which may
have the same cameras in more than one child folder.

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

### -SingleSelect

The ItemPicker allows for multiple items by default.
Supply this parameter to force selection of a single item.

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

### -Title

Specifies the text in the title-bar of the Item Picker window.
The default is "Select Camera(s)".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: Select Camera(s)
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
