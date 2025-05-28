---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Export-VmsRule/
schema: 2.0.0
---

# Export-VmsRule

## SYNOPSIS
Exports the specified rule(s) into a simplified and portable JSON format.

## SYNTAX

```
Export-VmsRule [-Rule <ConfigurationItem[]>] [[-Path] <String>] [-PassThru] [-Force] [<CommonParameters>]
```

## DESCRIPTION
The `Export-VmsRule` cmdlet exports rules to simplified PSCustomObjects and/or
JSON objects on disk. These exported rules can be used for reporting, or for
rebuilding rules on the same, or a different XProtect Management Server.

Note that when importing rules, the ID's of the devices, time profiles, events,
and other items referenced in the rule definitions must exist with either the
same ID, or at least the same name, otherwise the rules will fail to import.

When importing rules with references to user-defined events, generic events, or
analytic events, it may be enough for the properties in the rule definitions to
reference the events by name. However, for rules with references to specific
cameras or other devices, or device groups, you must modify the rule
definitions to include the item "Paths" or ID's as needed prior to importing.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1
```powershell
Export-VmsRule -Path ~\Desktop\rules.json
```

Exports all rules in JSON format to a file named "rules.json" on the desktop of
the current user profile.

### EXAMPLE 2
```powershell
Get-VmsRule -Name *Default* | Export-VmsRule -Path ~\Desktop\default-rules.json
```

Exports all rules with the word "Default" in the name to a file named
"default-rules.json" on the desktop of the current user profile.

### EXAMPLE 3
```powershell
Get-VmsRule -Name *Default* | Export-VmsRule -PassThru | Foreach-Object {
    $_ | New-VmsRule -Name "Copy of $($_.DisplayName)"
}
```

Exports all rules with the word "Default" in the name and then creates copies
with names prepended with "Copy of ".

## PARAMETERS

### -Force
Specifies the file at the path specified should be overwritten if it exists.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Specifies that the simplified rule definition should be returned to the pipeline.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Specifies the full path to a file where the JSON formatted rule definitions
should be exported. If the file already exists, you must include `-Force` to
indicate that the file should be overwritten.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Rule
Specifies one or more rules returned by Get-VmsRule. When omitted, all rules
will be exported. Rules may be provided by name and names will be tab-completed.

REQUIREMENTS  

- Allowed item types: Rule

```yaml
Type: ConfigurationItem[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.ConfigurationApi.ClientService.ConfigurationItem

## OUTPUTS

### PSCustomObject

## NOTES
Milestone's Configuration API does not support all possible types of rules,
and some rules defined in Management Client may not be returned by
Get-VmsRule or exported with Export-VmsRule.
See the \[Rules Configuration\](https://doc.developer.milestonesys.com/html/index.html?base=gettingstarted/intro_configurationapi.html&tree=tree_4.html)
section of the configuration api getting-started guide in Milestone's MIP
SDK documentation for more information.

## RELATED LINKS
