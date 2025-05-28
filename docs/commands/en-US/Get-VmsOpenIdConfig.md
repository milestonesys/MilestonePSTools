---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsOpenIdConfig/
schema: 2.0.0
---

# Get-VmsOpenIdConfig

## SYNOPSIS
Gets the OpenID Connect configuration document from the current site, or specified URI.

## SYNTAX

```
Get-VmsOpenIdConfig [[-Address] <Uri>] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsOpenIdConfig` cmdlet gets the OpenID Connect configuration document from the current site, or specified URI
and returns it as a PSCustomObject. This is used by the module to retrieve the "issuer" string to configure
TrustedIssuers, and it is a useful JSON document for diagnostic purposes.

The OpenID Connect configuration document is available at https://managementserver/IDP/.well-known/openid-configuration,
where "managementserver" is the IP, hostname, or fully-qualified hostname of the management server.

REQUIREMENTS  

- None specified

## EXAMPLES

### EXAMPLE 1
```
Get-VmsOpenIdConfig -Address https://managementserver
```

Gets the openid-configuration document from the management server on the local host.

### EXAMPLE 2
```
Get-VmsOpenIdConfig
```

Gets the openid-configuration document from the management server currently connected to using Connect-Vms.

## PARAMETERS

### -Address
Specifies the URL for a Milestone XProtect Management Server.
When provided, the path of the URL will be set to "/IDP/.well-known/openid-configuration".
When no address is provided, the address is retrieved from the current MilestonePSTools session using \`Get-LoginSettings\`.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### [PSCustomObject]

## NOTES

## RELATED LINKS
