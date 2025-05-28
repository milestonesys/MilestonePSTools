---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsView/
schema: 2.0.0
---

# Get-VmsView

## SYNOPSIS
Gets one or more views which are typically defined in XProtect Smart Client.

## SYNTAX

### Default (Default)
```
Get-VmsView [-ViewGroup <ViewGroup[]>] [[-Name] <String[]>] [<CommonParameters>]
```

### ById
```
Get-VmsView [-Id] <Guid> [<CommonParameters>]
```

## DESCRIPTION
Gets one or more View objects which are children of ViewGroup containers. Views
have a layout defined in XML, and contain one ViewItemChildItem for each "pane"
in the view where a camera or other view item can be placed.

The ViewItemChildItem objects are further defined by their own ViewItem xml which
describes the content of that view item within the overall view.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
Get-VmsView

<# OUTPUT
DisplayName      ViewSize Shortcut Id                       LastModified
-----------      -------- -------- --                       ------------
New View (1 x 2) 2                 78904DC2-20FF-4F47-97... 3/25/2020 3:23:19 PM
New View (1 + 7) 8                 7BE65A12-2997-4783-A5... 3/25/2020 1:24:12 PM
#>
```

After ensuring there is an open connection to the Management Server, we retrieve
a list of all views in all view groups.

### Example 2
```powershell
$parentViewGroup = Get-VmsViewGroup | Out-GridView -OutputMode Single
$parentViewGroup | Get-VmsViewGroup -Recurse | Get-VmsView

<# OUTPUT
DisplayName      ViewSize Shortcut Id                       LastModified
-----------      -------- -------- --                       ------------
New View (1 x 2) 2                 78904DC2-20FF-4F47-97... 3/25/2020 3:23:19 PM
New View (1 + 7) 8                 7BE65A12-2997-4783-A5... 3/25/2020 1:24:12 PM
#>
```

Returns all views from all child view groups of the selected parent view group.

## PARAMETERS

### -Id
Specifies the ID of a specific view.

```yaml
Type: Guid
Parameter Sets: ById
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies the view name with support for wildcards.

```yaml
Type: String[]
Parameter Sets: Default
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### -ViewGroup
Specifies the parent view group from which views should be returned.

```yaml
Type: ViewGroup[]
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.ViewGroup

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.View

## NOTES

Due to a bug in XProtect VMS versions released before 2022 R2, views that are
nested in subgroups will all appear to be duplicated in each parent group when
accessing the view group configuration through the Configuration API. Since
MilestonePSTools uses the Configuration API to access view group information,
view locations may not appear to match XProtect Smart Client unless you are
running version 2022 R2 or later, or unless the issue is resolved in a cumulative
patch for your VMS version.

## RELATED LINKS
