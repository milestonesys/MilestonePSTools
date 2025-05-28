---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsWebhook/
schema: 2.0.0
---

# Remove-VmsWebhook

## SYNOPSIS
Removes an existing webhook from a Milestone XProtect VMS.

## SYNTAX

### Path (Default)
```
Remove-VmsWebhook -Path <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Name
```
Remove-VmsWebhook [-Name] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsWebhook` cmdlet removes an existing webhook from a Milestone XProtect VMS. The webhook to be removed can
be specified by Name, or configuration item path. When removing a webhook by name, wildcards will not be evaluated and
if there are multiple webhooks with the same name (case-insensitive), an error will be returned.

REQUIREMENTS  

- Requires VMS version 23.1
- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1
```powershell
Get-VmsWebhook | Remove-VmsWebhook -WhatIf
```

Removes all configured webhooks if you remove the `-WhatIf` switch.

### EXAMPLE 2
```powershell
Get-VmsWebhook -Name 'Test Webhook' | Remove-VmsWebhook -WhatIf
```

Removes all webhooks named 'Test webhook' if you remove the `-WhatIf` switch.

### EXAMPLE 3
```powershell
Remove-VmsWebhook -Name 'Test Webhook' -ErrorAction SilentlyContinue -WhatIf
```

Removes a single webhook named 'Test Webhook' if the `-WhatIf` switch is removed. If the webhook is not found, or there
are multiple webhooks with the same name, an error would normally be returned. However, the addition of
`-ErrorAction SilentlyContinue` will silence any errors.

## PARAMETERS

### -Name
Specifies the name of the webhook to remove. If the name contains a wildcard character, it will not be evaluated. The
name must match exactly one webhook using case-insensitive comparison.

```yaml
Type: String
Parameter Sets: Name
Aliases: DisplayName

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path
Specifies the exact Configuration Item path for the webhook to remove. This value is formatted like
`MIPItem[1a33142f-c35b-420f-bdd7-30240de4e9ef]` and in most cases you will pass the value of Path from the pipeline by
property name.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### System.String

## OUTPUTS

### None

## NOTES

Supported on Milestone XProtect VMS versions 2023 R1 and later.

## RELATED LINKS
