---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsViewGroup/
schema: 2.0.0
---

# New-VmsViewGroup

## SYNOPSIS
Creates a new top-level or child view group for XProtect Smart Client.

## SYNTAX

```
New-VmsViewGroup [-Name] <String> [-Parent <ViewGroup>] [-Description <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
There are two types of view groups - top-level view groups which are usually
created or removed in Management Client, and can have permissions applied on a
per-role level, and cannot directly contain view child items, and child view
groups which can be nested within a top-level view group, and may contain views,
and share the permissions of the top-level view group above it.

This command can be used to create any type of view group - the Milestone SDK
does not differentiate between the two, except that you cannot add views directly
to a top-level view group, and you cannot change permissions on a child view group.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$parentViewGroup = New-VmsViewGroup -Name 'New-VmsViewGroup Test' -Force
$subgroup1 = $parentViewGroup | New-VmsViewGroup -Name 'SubGroup 1' -Force
$subgroup2 = New-VmsViewGroup -Name 'SubGroup 2' -Parent $subgroup1 -Force
$subgroup1
$subgroup2
```

After ensuring there is an open connection to the Management Server, three nested
groups are created with the top-level view group 'New-VmsViewGroup Test' having
a child view group named "SubGroup 1" and the child view group having it's own
child view group named "SubGroup 2".

## PARAMETERS

### -Description
Specifies the view group description which is only displayed in Management Client
for top-level view groups.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Specifies that the view group should be created, and if it already exists, the
existing view group should be returned without error.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of the new view group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Parent
Specifies the parent view group. This parameter is required when creating a nested
or "child" view group.

```yaml
Type: ViewGroup
Parameter Sets: (All)
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

### VideoOS.Platform.ConfigurationItems.ViewGroup

## NOTES

## RELATED LINKS
