---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsRule/
schema: 2.0.0
---

# Remove-VmsRule

## SYNOPSIS
Removes an existing rule.

## SYNTAX

```
Remove-VmsRule [-Rule] <ConfigurationItem> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsRule` cmdlet removes an existing rule from the VMS.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.1

## EXAMPLES

### Example 1
```powershell
$copiedRule = Get-VmsRule | Get-Random | New-VmsRule -Name 'TEMPORARY COPY'
$copiedRule | Remove-VmsRule
```

Creates a copy of a random rule, and then removes the copied rule.

## PARAMETERS

### -Rule
Specifies one or more rules returned by Get-VmsRule. When omitted, all rules
will be exported. Rules may be provided by name and names will be tab-completed.

REQUIREMENTS  

- Allowed item types: Rule

```yaml
Type: ConfigurationItem
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

### VideoOS.ConfigurationApi.ClientService.ConfigurationItem

## OUTPUTS

### None

## NOTES

## RELATED LINKS
