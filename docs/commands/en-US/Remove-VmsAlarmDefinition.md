---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsAlarmDefinition/
schema: 2.0.0
---

# Remove-VmsAlarmDefinition

## SYNOPSIS
Removes one or more alarm definitions.

## SYNTAX

```
Remove-VmsAlarmDefinition [-AlarmDefinition] <AlarmDefinition[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsAlarmDefinition` cmdlet removes one or more alarm definitions.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsAlarmDefinition 'Camera not responding' | Remove-VmsAlarmDefinition
```

Finds all alarm definitions with the given name and removes them.

### Example 1
```powershell
Get-VmsAlarmDefinition | Remove-VmsAlarmDefinition -WhatIf
```

Deletes all alarm definitions.

## PARAMETERS

### -AlarmDefinition
Specifies one or more alarm definitions as returned by `Get-VmsAlarmDefinition`.

```yaml
Type: AlarmDefinition[]
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

### VideoOS.Platform.ConfigurationItems.AlarmDefinition[]

## OUTPUTS

### None

## NOTES

## RELATED LINKS
