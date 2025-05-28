---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsViewGroup/
schema: 2.0.0
---

# Get-VmsViewGroup

## SYNOPSIS
Gets one or more top-level or child view groups as seen in XProtect Smart Client.

## SYNTAX

### Default
```
Get-VmsViewGroup [-Parent <ViewGroup>] [[-Name] <String[]>] [-Recurse] [<CommonParameters>]
```

### ById
```
Get-VmsViewGroup [-Id] <Guid> [<CommonParameters>]
```

## DESCRIPTION
View groups are containers for groups and views. Top-level view groups are defined
in Management Client and permissions can be set per role for these top-level groups.

In XProtect Smart Client, you will normally see a "Private" view group which is unique to
your user account, and zero or more additional view groups depending on your system
configuration. These view groups cannot directly contain views, but they can contain
one or more child view groups. Views and view groups can be nested.

Use this command to retrieve view groups and inspect or modify their contents,
or adjust permissions for roles using the `*-VmsViewGroupAcl` commands.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
Get-VmsViewGroup

<# OUTPUT
DisplayName     Id                                   LastModified
-----------     --                                   ------------
Private         5C72A7B2-E3A8-4FF1-9F97-85C99D91E9D1 10/5/2017 5:21:01 PM
Main View Group 95DA86DD-386D-4159-87D8-00885CE29407 10/22/2017 9:38:44 PM
LPR             B3E356AF-1F4A-4557-A8D5-CAE7641384D6 10/19/2018 11:03:10 PM
#>
```

After ensuring there is an open connection to the Management Server, we retrieve
a list of all view groups.

### Example 2
```powershell
$viewgroup = Get-VmsViewGroup | Out-GridView -OutputMode Single
$viewGroup | Get-VmsViewGroup -Recurse

<# OUTPUT
DisplayName Id                                   LastModified
----------- --                                   ------------
New Group   9CDCFC6C-CE51-403E-8410-C8EB1F317D12 3/13/2019 9:27:21 PM
#>
```

In this example you will be prompted to select from one of the top-level view groups,
and then all child view groups, recursively, will be returned.

### Example 3
```powershell
Get-VmsViewGroup -Name 'Main View Group' -Recurse | Get-VmsView

<# OUTPUT
DisplayName      ViewSize Shortcut Id                       LastModified
-----------      -------- -------- --                       ------------
New View (1 x 2) 2                 78904DC2-20FF-4F47-97... 3/25/2020 3:23:19 PM
New View (1 + 7) 8                 7BE65A12-2997-4783-A5... 3/25/2020 1:24:12 PM
#>
```

In this example, we recursively seek all view groups inside the top-level
'Main View Group` group, and then return all views in all child view groups.

## PARAMETERS

### -Id
Specifies the ID of a specific view group. It can be a top-level, or child view group.

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
Specifies the view group name with support for wildcards.

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

### -Parent
Specifies a parent view group object. Useful for retrieving child view groups
from a specific parent view group.

```yaml
Type: ViewGroup
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Recurse
Specifies that all child view groups should be returned recursively.

```yaml
Type: SwitchParameter
Parameter Sets: Default
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.ViewGroup

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ViewGroup
## NOTES

## RELATED LINKS
