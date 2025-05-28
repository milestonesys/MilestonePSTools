---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsTrustedIssuer/
schema: 2.0.0
---

# New-VmsTrustedIssuer

## SYNOPSIS
Creates a new Trusted Issuer on the current Milestone XProtect VMS.

## SYNTAX

```
New-VmsTrustedIssuer [[-Address] <Uri>] [<CommonParameters>]
```

## DESCRIPTION
The `New-VmsTrustedIssuer` cmdlet is used to create a new `TrustedIssuer` record on a child site in a Milestone
XProtect VMS to add a parent site as a trusted issuer of tokens. This is necessary to allow single sign-on using an
external identity provider such as Azure, in a Milestone Federated Architecture hierarchy.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires a VMS connection using a Windows, or Active Directory user account.
- Requires VMS feature "FederatedSites"

## EXAMPLES

### EXAMPLE 1
```
New-VmsTrustedIssuer
```

Creates a new TrustedIssuer record using the MasterSiteAddress property found using `(Get-VmsManagementServer).MasterSiteAddress`.

### EXAMPLE 2
```
New-VmsTrustedIssuer -Address https://parentsite.domain/
```

Creates a new TrustedIssuer record by discovering the "issuer" address from "https://parentsite.domain/IDP/.well-known/openid-configuration".

## PARAMETERS

### -Address
Specifies the address of the trusted Milestone Identity Provider (IDP). This should be the address of the parent
management server.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Management.VmoClient.TrustedIssuer

## NOTES
You must be logged in to the child site using a Windows account.
Trusted Issuer records currently cannot be managed
using a basic user account or an external identity.

## RELATED LINKS
