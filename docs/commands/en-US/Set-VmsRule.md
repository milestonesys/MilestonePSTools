---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsRule/
schema: 2.0.0
---

# Set-VmsRule

## SYNOPSIS
Sets one or more properties of an existing VMS rule.

## SYNTAX

```
Set-VmsRule [-Rule] <ConfigurationItem> [[-Name] <String>] [[-Enabled] <Boolean>] [[-Properties] <Hashtable>]
 [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsRule` cmdlet sets one or more properties of an existing VMS rule.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.1

## EXAMPLES

### Example 1
```powershell
Get-VmsRule | Foreach-Object {
    $_ | Set-VmsRule -Name "Renamed - $($_.DisplayName)" -Enabled $false -Verbose -WhatIf
}
```

Renames and disables all rules supported by Configuration API if the `-WhatIf` switch
is removed.

## PARAMETERS

### -Enabled
Specifies a new desired enabled-state - either `$true` or `$false`.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies a new name / display name.

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
Specifies that the updated rule should be returned to the pipeline. When used
with the `-WhatIf` switch, the unmodified rule will be returned to the pipeline.

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

### -Properties
Specifies a collection of properties either as a hashtable, or as list of
objects, each having a Key and a Value property. For example, you can pass in
the `Properties` collection from the result of `Get-VmsRule` and the Key/Value
properties from each of the properties in the collection will be automatically
converted to a hashtable when calling `New-VmsRule`.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

### VideoOS.ConfigurationApi.ClientService.ConfigurationItem[]

## OUTPUTS

### VideoOS.ConfigurationApi.ClientService.ConfigurationItem

## NOTES

## RELATED LINKS
