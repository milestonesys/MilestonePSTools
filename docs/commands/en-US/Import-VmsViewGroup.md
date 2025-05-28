---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Import-VmsViewGroup/
schema: 2.0.0
---

# Import-VmsViewGroup

## SYNOPSIS
Exports an XProtect Smart Client view group and all contents to a JSON file.

## SYNTAX

```
Import-VmsViewGroup [-Path] <String> [[-NewName] <String>] [[-ParentViewGroup] <ViewGroup>]
 [<CommonParameters>]
```

## DESCRIPTION
Imports an XProtect Smart Client view group from a JSON file previously generated
using the `Export-VmsViewGroup` command. You may import an exported view group
on the same Management Server, or a different Management Server than the
original view group.

The selected view group can be a top-level view group, or a child view group.
However, if you import a view group which has directly-attached views that are
not nested in a child view group, those views will be lost when importing the
view group as a top-level view group.

When a parent ViewGroup is provided in the ParentViewGroup parameter, the
imported view group will be inserted as a child of the designated parent.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$viewGroup = Get-VmsViewGroup | Out-GridView -OutputMode Single
$viewGroup | Export-VmsViewGroup -Path C:\temp\viewgroup.json -Force
Import-VmsViewGroup -Path 'C:\temp\viewgroup.json' -NewName "$($viewGroup.DisplayName) Copy"
```

After ensuring there is an open connection to the Management Server, we prompt
for a view group selection. The selected view group is then exported to a json
file at C:\temp\viewgroup.json. Next, the view group is imported under the same
name with "Copy" appended to it.

### Example 2
```powershell
$viewGroup = Get-VmsViewGroup | Out-GridView -OutputMode Single
$viewGroup | Export-VmsViewGroup -Path C:\temp\viewgroup.json -Force

$viewGroup = New-VmsViewGroup -Name "$($viewGroup.DisplayName) Copy" -Force
$dstViewGroup = $viewGroup | New-VmsViewGroup -Name "Child View Group"
$params = @{
    Path = 'C:\temp\viewgroup.json'
    ParentViewGroup = $dstViewGroup
    NewName = 'Example 2'
}
Import-VmsViewGroup @params
```

This example demonstrates that it is possible to export a top-level view group
and then import the view group as a nested child view group inside a different
parent view group.

## PARAMETERS

### -NewName
Specifies an optional new name for the imported view group. If a view group with
the same name already exists, the import will not proceed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParentViewGroup
Specifies an optional parent view group within which the imported view group
should be nested. If omitted, the imported view group will become a new top-level
view group.

```yaml
Type: ViewGroup
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Specifies the path to a file where a JSON representation of the view group
will be imported. The file should be generated using Export-VmsViewGroup.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
