---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Export-VmsViewGroup/
schema: 2.0.0
---

# Export-VmsViewGroup

## SYNOPSIS
Exports an XProtect Smart Client view group and all contents to a JSON file.

## SYNTAX

```
Export-VmsViewGroup [-ViewGroup] <ViewGroup> [-Path] <String> [-Force] [<CommonParameters>]
```

## DESCRIPTION
Exports an XProtect Smart Client view group and all contents to a JSON file which
can be used to import the view group on the same Management Server, or a different
Management Server.

The selected view group can be a top-level view group, or a child view group.
However, if you import a view group which has directly-attached views that are
not nested in a child view group, those views will be lost when importing the
view group as a top-level view group.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$viewGroup = Get-VmsViewGroup | Out-GridView -OutputMode Single
$viewGroup | Export-VmsViewGroup -Path C:\temp\viewgroup.json
```

After ensuring there is an open connection to the Management Server, we prompt
for a view group selection. The selected view group is then exported to a json
file at C:\temp\viewgroup.json.

## PARAMETERS

### -Force
Specifies that the destination directory should be created if it doesn't exist,
and if the destination file exists, it should be overwritten.

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

### -Path
Specifies the path to a file where a JSON representation of the view group
will be saved

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

### -ViewGroup
The view group to be exported, along with all child members, recursively.

```yaml
Type: ViewGroup
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.ViewGroup

## OUTPUTS

### None

## NOTES

## RELATED LINKS
