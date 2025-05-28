---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Clear-VmsSiteInfo/
schema: 2.0.0
---

# Clear-VmsSiteInfo

## SYNOPSIS
Clears all site information properties.

## SYNTAX

```
Clear-VmsSiteInfo [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet clears all site information properties which are displayed in the Management Client under
Site / Basics / Site Information.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.2

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptAula
Clear-VmsSiteInfo -WhatIf
```

After connecting to the Management Server, this command shows what would happen
if the site information was cleared. Specifically, it would tell you what fields
would be removed if you were to run the command without the -WhatIf switch.

## PARAMETERS

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

### None

## OUTPUTS

### None

## NOTES

## RELATED LINKS
