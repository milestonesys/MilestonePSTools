---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Import-VmsRule/
schema: 2.0.0
---

# Import-VmsRule

## SYNOPSIS
Imports rules that have been exported using Export-VmsRule.

## SYNTAX

### FromObject
```
Import-VmsRule -InputObject <Object[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### FromFile
```
Import-VmsRule [-Path] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Import-VmsRule` cmdlet imports rules that have been exported using
Export-VmsRule. Note that when importing rules, the ID's of the devices, time
profiles, events, and other items referenced in the rule definitions must exist
with either the same ID, or at least the same name, otherwise the rules will
fail to import.

When importing rules with references to user-defined events,
generic events, or analytic events, it may be enough for the properties in the
rule definitions to reference the events by name. However, for rules with
references to specific cameras or other devices, or device groups, you must
modify the rule definitions to include the item "Paths" or ID's as needed prior
to importing.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.1

## EXAMPLES

### EXAMPLE 1
```powershell
Export-VmsRule -Path ~\Desktop\rules.json
Import-VmsRule -Path ~\Desktop\rules.json -WhatIf
```

Exports all rules available through the Configuration API to a file on the
desktop named "rules.json".

Then the rules are imported, which would normally create new rules with duplicate
names unless the previously exported rules have been renamed or deleted, or the
definitions for the rules to be imported have been manually provided with unique
DisplayName values.

Thanks to the presence of the `-WhatIf` switch, you will only see what would
happen if you ran the command again without `-WhatIf`.

## PARAMETERS

### -InputObject
Specifies one or more `[pscustomobject]` objects which are returned by the
`Export-VmsRule` function when using the -PassThru switch.

```yaml
Type: Object[]
Parameter Sets: FromObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Specifies the path to a JSON file created by the Export-VmsRule function.

```yaml
Type: String
Parameter Sets: FromFile
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
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

### String

### PSCustomObject

## OUTPUTS

### VideoOS.ConfigurationApi.ClientService.ConfigurationItem

## NOTES

## RELATED LINKS
