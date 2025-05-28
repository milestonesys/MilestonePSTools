---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsViewGroup/
schema: 2.0.0
---

# Remove-VmsViewGroup

## SYNOPSIS
Removes one or more XProtect Smart Client view groups.

## SYNTAX

```
Remove-VmsViewGroup [-ViewGroup] <ViewGroup[]> [-Recurse] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Views groups are typically used in XProtect Smart Client and can contain one or more
views with camera view items or other types of view items like maps, alarm
lists, and images and browsers.

This cmdlet allows you to permanently delete one or more views group containers.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$viewGroup = Get-VmsViewGroup -Recurse | Out-GridView -OutputMode Single
$viewGroup | Remove-VmsViewGroup -Recurse -WhatIf
```

After ensuring there is an open connection to the Management Server, we retrieve
a list of all view groups, present a grid view dialog where one view group
may be selected, and this view group is passed to `Remove-VmsViewGroup` with the
-WhatIf switch to ensure that no view groups are actually deleted.

To delete a view group, you can omit the -WhatIf switch parameter. Add the -Verbose
switch to see detailed messages for each deleted view group.

## PARAMETERS

### -Recurse
Specifies that all child members, including views and view groups, should be recursively removed.

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
Specifies one or more view groups to be permanently removed.

```yaml
Type: ViewGroup[]
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

## NOTES

On Milestone versions older than 2022 R2, the -Recurse switch does not work. You
must delete all child views and view groups before you can delete the parent view group.

This is an issue with the configuration api service on the Management Server.

## RELATED LINKS
