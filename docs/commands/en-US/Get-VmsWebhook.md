---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsWebhook/
schema: 2.0.0
---

# Get-VmsWebhook

## SYNOPSIS
Get existing webhooks from a Milestone XProtect VMS by Name, or configuration item path.

## SYNTAX

### Path (Default)
```
Get-VmsWebhook [-Path <String>] [<CommonParameters>]
```

### Name
```
Get-VmsWebhook [[-Name] <String>] [<CommonParameters>]
```

### LiteralName
```
Get-VmsWebhook [-LiteralName <String>] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsWebhook` cmdlet returns existing webhooks from a Milestone XProtect VMS.

All webhooks can be retrieved calling the cmdlet without parameters, or specific webhooks can be retrieved by name or
"path".

Note that with Milestone's Configuration API, a path for a configuration item like a webhook looks like
`MIPItem[1a33142f-c35b-420f-bdd7-30240de4e9ef]` which is a special value representing the item type, "MIPItem" in this
case, and the ID of the item, "1a33142f-c35b-420f-bdd7-30240de4e9ef".

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 23.1

## EXAMPLES

### EXAMPLE 1
```powershell
Get-VmsWebhook
```

Get all configured webhooks.

### EXAMPLE 2
```powershell
Get-VmsWebhook -Name Test*
```

Get all configured webhooks with names beginning with the word "Test".

### EXAMPLE 3
```powershell
Get-VmsWebhook -LiteralName Test*
```

Gets the webhook(s) with the literal name "Test*". When using the LiteralName parameter, wildcard characters are not
evaluated as wildcards.

## PARAMETERS

### -LiteralName
Specifies the exact, case-insensitive name of the webhook.

```yaml
Type: String
Parameter Sets: LiteralName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies the name of the webhook with support for wildcards.

```yaml
Type: String
Parameter Sets: Name
Aliases: DisplayName

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -Path
Specifies the exact Configuration Item path for the webhook.
This value is formatted like "MIPItem\[1a33142f-c35b-420f-bdd7-30240de4e9ef\]"
and in most cases you will pass the value of Path from the pipeline by property name.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### MilestonePSTools.Webhook

## NOTES

Supported on Milestone XProtect VMS versions 2023 R1 and later.

## RELATED LINKS
