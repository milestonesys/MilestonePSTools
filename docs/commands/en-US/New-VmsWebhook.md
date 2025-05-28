---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsWebhook/
schema: 2.0.0
---

# New-VmsWebhook

## SYNOPSIS
Create a new webhook on a Milestone XProtect VMS.

## SYNTAX

```
New-VmsWebhook [-Name] <String> -Address <Uri> [-Token <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `New-VmsWebhook` cmdlet creates a new webhook definition on a Milestone XProtect VMS.

Webhooks must have a name, and address, and the name _should_ be unique, but this is not enforced by the VMS and you
will not receive any warnings or errors when a webhook is created with a duplicate name.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 23.1

## EXAMPLES

### EXAMPLE 1
```powershell
New-VmsWebhook -Name 'Sample Webhook' -Address https://webhook.destination/
```

Creates a new webhook, without the use of a token. The HTTP POST messages will still include the "x-hub-signature-256"
HTTP header, and the HMAC signature will be generated using an empty string as the secret.

### EXAMPLE 2
```powershell
New-VmsWebhook -Name 'Sample Webhook' -Address https://webhook.destination/ -Token 'My secret token'
```

Creates a new webhook with a token to use when signing the HTTP POST.

### EXAMPLE 3
```powershell
Import-Csv -Path ~\webhooks.csv | New-VmsWebhook
```

This example demonstrates how you can use a CSV file with Name, Address, and optional Token headers to create new
webhooks in your Milestone VMS.

## PARAMETERS

### -Address
Specifies a web address such as <https://webhook.destination/> or <http://webhook.destination/>.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies the name of the new webhook. Names should ideally be unique, but this is not enforced by the VMS.

```yaml
Type: String
Parameter Sets: (All)
Aliases: DisplayName

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Token
Specifies an optional "secret key" to sign webhook payloads enabling the recipient to authenticate the request, and
validate the payload. The value provided will be used to generate a "x-hub-signature-256" HTTP header containing a
SHA256 HMAC hash of the payload which will look like "x-hub-signature-256: sha256=yR8FWeS1nsIZw36dN1FXz7aRNbcr/O0F8m41F6yBopY=".

If no token is provided, the "x-hub-signature-256" header will still be present in the HTTP requests, and the HMAC key
used to generate the SHA256 hash will be an empty string.

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

See this [Securing your webhooks](https://docs.github.com/en/webhooks-and-events/webhooks/securing-your-webhooks) article
from GitHub for more information about the "x-hub-signature-256" header.

For testing purposes, the [Webhook.site](https://webhook.site) web service is a fantastic way to evaluate whether your webhooks
are working, and inspect the headers and payloads to better understand how to use them in your third-party application.

## RELATED LINKS
