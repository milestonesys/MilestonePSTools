---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Select-VideoOSItem/
schema: 2.0.0
---

# Select-VideoOSItem

## SYNOPSIS

Offers a UI dialog for selecting items, similar to the item selection interface in Management Client.

## SYNTAX

```
Select-VideoOSItem [[-Title] <String>] [[-Kind] <Guid[]>] [[-Category] <Category[]>] [-SingleSelect]
 [-AllowFolders] [-AllowServers] [-KindUserSelectable] [-CategoryUserSelectable] [-FlattenOutput]
 [-HideGroupsTab] [-HideServerTab] [[-OwnerHandle] <IntPtr>] [<CommonParameters>]
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
Select-VideoOSItem -Title "Select Microphone(s)" -AllowServers -HideGroupsTab -Kind ([VideoOS.Platform.Kind]::Microphone) | ForEach-Object { Send-MipMessage -MessageId 'Control.StartRecordingCommand' -DestinationEndpoint $_.FQID -UseEnvironmentManager }
```

Launch the Item Picker and hide the Groups tab, showing only the system-definied hierarchy of servers under the Server tab, and
filter the items to only Microphones.
For each selected Microphone, send a manual "Start Recording" message.

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

### -Category

One or more \[VideoOS.Platform.Admin.Category\] values representing the types of items to populate in the picker,
such as \[VideoOS.Platform.Admin.Category\]::VideoIn.
Omitting a value means the list in the picker will be unfiltered.

```yaml
Type: Category[]
Parameter Sets: (All)
Aliases:
Accepted values: Server, VideoIn, VideoOut, AudioIn, AudioOut, TriggerIn, TriggerOut, Text, Unknown, Layout

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CategoryUserSelectable

Supply this switch to enable a drop-down list in the UI for the user to filter the Category themselves.

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

### -FlattenOutput

When you allow groups/folders to be selectable, the result will not directly include the child items of those folders
unless you supply this switch.

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

### -HideGroupsTab

Supply this switch to hide the Groups tab, leaving only the Server tab which shows the "SystemDefined" hierarchy.

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

### -HideServerTab

Supply this switch to hide the Server tab, leaving only the Groups tab which shows the "UserDefined" hierarchy.

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

### -OwnerHandle

Specifies an optional UI owner window handle to make the dialog modal to an existing GUI window.

```yaml
Type: IntPtr
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Kind

One or more Guids representing a type of object in Milestone.
Use Get-Kind -List to see the available Kinds
or use \[VideoOS.Platform.Kind\] to access a set of static Kind guids, such as \[VideoOS.Platform.Kind\]::Camera.
Omitting a value means the list in the picker will be unfiltered.

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -KindUserSelectable

Supply this switch to enable a drop-down list in the UI for the user to filter the Kind themselves.

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
The default is "Select Item(s)".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: Select Item(s)
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
