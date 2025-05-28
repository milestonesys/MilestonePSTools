---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsView/
schema: 2.0.0
---

# Remove-VmsView

## SYNOPSIS
Removes one or more XProtect Smart Client views.

## SYNTAX

```
Remove-VmsView [-View] <View[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Views are typically used in XProtect Smart Client and can contain one or more camera view
items or other types of view items like maps, alarm lists, and images and browsers.

This cmdlet allows you to permanently delete one or more views.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
Get-VmsView | Out-GridView -OutputMode Single | Remove-VmsView -WhatIf
```

After ensuring there is an open connection to the Management Server, we retrieve
a list of all views in all view groups, present a grid view dialog where one view
may be selected, and this view is passed to `Remove-VmsView` with the -WhatIf
switch to ensure that no views are actually deleted.

To delete a view, you can omit the -WhatIf switch parameter. Add the -Verbose
switch to see detailed messages for each deleted view.

## PARAMETERS

### -View
Specifies one or more views to be deleted. Views are easily selected using Get-VmsView.

```yaml
Type: View[]
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
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

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

### VideoOS.Platform.ConfigurationItems.View

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.View

## NOTES

## RELATED LINKS
