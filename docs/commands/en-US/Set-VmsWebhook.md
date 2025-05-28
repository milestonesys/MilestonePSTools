---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsWebhook/
schema: 2.0.0
---

# Set-VmsWebhook

## SYNOPSIS
Updates the settings of an existing webhook on a Milestone XProtect VMS.

## SYNTAX

### Path (Default)
```
Set-VmsWebhook -Path <String> [-NewName <String>] [-Address <Uri>] [-Token <String>] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

### Name
```
Set-VmsWebhook [-Name] <String> [-NewName <String>] [-Address <Uri>] [-Token <String>] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsWebhook` cmdlet updates the specified properties of an existing webhook on a Milestone XProtect VMS.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 23.1

## EXAMPLES

### EXAMPLE 1
```powershell
Get-VmsWebhook -Name 'Test webhook' | Set-VmsWebhook -NewName 'My Test Webhook'
```

Gets all webhooks named "Test webhook" and updates the name to "My Test Webhook"

### EXAMPLE 2
```powershell
Import-Csv -Path ~\webhooks.csv | Set-VmsWebhook -ErrorAction SilentlyContinue -PassThru
```

Imports webhook settings from a CSV file and updates any matching webhooks, returning the updated webhooks to the pipeline.

## PARAMETERS

### -Address
Specifies a new web url for the matching webhook.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies the name of the webhook to update with new settings. Wildcard characters in the name will not be evaluated.

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

### -NewName
Specifies a new display name for the matching webhook.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -PassThru
Specifies that the updated webhook should be returned to the pipeline.

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
Specifies the Configuration API path for the webhook to be updated.

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

### -Token
Specifies a new token value to use when signing HTTP messages from the matching webhook.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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

### System.Uri

## OUTPUTS

### MilestonePSTools.Webhook

## NOTES

Supported on Milestone XProtect VMS versions 2023 R1 and later.

## RELATED LINKS
