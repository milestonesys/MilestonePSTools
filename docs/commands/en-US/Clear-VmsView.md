---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Clear-VmsView/
schema: 2.0.0
---

# Clear-VmsView

## SYNOPSIS
Clears all cameras or other view items from one or more XProtect Smart Client views.

## SYNTAX

```
Clear-VmsView [-View] <View[]> [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This command removes all view items from the view, leaving an empty view layout
with the same original layout.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$view = Get-VmsView | Out-GridView -OutputMode Single
$view | Clear-VmsView -WhatIf
```

After ensuring there is an open connection to the Management Server, we prompt
for a view selection, and then clear the view of all view items, except the
-WhatIf parameter is present, so you will only see a message indicating the change
that would occur if you omitted the -WhatIf switch.

## PARAMETERS

### -PassThru
Specifies that the updated view should be passed on through the pipeline, or out
to the terminal.

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

### -View
Specifies one or more views to be cleared of all view items.

```yaml
Type: View[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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

### VideoOS.Platform.ConfigurationItems.View[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.View

## NOTES

## RELATED LINKS
