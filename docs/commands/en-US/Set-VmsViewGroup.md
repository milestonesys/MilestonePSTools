---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsViewGroup/
schema: 2.0.0
---

# Set-VmsViewGroup

## SYNOPSIS
Sets properties of an existing XProtect Smart Client view group.

## SYNTAX

```
Set-VmsViewGroup [-ViewGroup] <ViewGroup> [[-Name] <String>] [[-Description] <String>] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This command is used to update the name or description of any top-level or child
view group. Note that the description is currently only displayed in Management
Client for top-level view groups. The descriptions of nested child view groups
are not used by XProtect Smart Client.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$viewGroup = New-VmsViewGroup -Name 'MilestonePSTools Example' -Force
$viewGroup | Set-VmsViewGroup -Name 'Example 1' -PassThru
$viewGroup | Remove-VmsViewGroup
```

After ensuring there is an open connection to the Management Server, we create
a view group to test with. On the third line, the view group is renamed and thanks
to the -PassThru switch, we see the updated view group properties in the terminal.

Finally, we clean up by removing the newly created view group.

## PARAMETERS

### -Description
Specifies a new description for the view group.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies a new name for the view group.

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

### -PassThru
Specifies that the modified view group should be returned to the pipeline.

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

### -ViewGroup
The view group to be updated. Typically retrieved using Get-VmsViewGroup.

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

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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
