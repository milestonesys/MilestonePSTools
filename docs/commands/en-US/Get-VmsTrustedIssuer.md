---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsTrustedIssuer/
schema: 2.0.0
---

# Get-VmsTrustedIssuer

## SYNOPSIS
Gets one or more TrustedIssuer records from the current Milestone XProtect VMS.

## SYNTAX

```
Get-VmsTrustedIssuer [[-Id] <Int32>] [-Refresh] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsTrustedIssuer` cmdlet gets one or more TrustedIssuer records from the current Milestone XProtect VMS.

A TrustedIssuer must be added to a child site in a Milestone Federated Architecture hierarchy when using an external
identity provider such as Azure for single sign-on to a parent site and all child sites in the hierarchy.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires a VMS connection using a Windows, or Active Directory user account.
- Requires VMS feature "FederatedSites"

## EXAMPLES

### EXAMPLE 1
```
Get-VmsTrustedIssuer | Select-Object Id, Issuer, Address
```

Gets a list of existing TrustedIssuer records and returns the Id, Issuer, and Address properties.

## PARAMETERS

### -Id
Specifies the integer ID value for the TrustedIssuer record to retrieve.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Refresh
Specifies that any previously cached copies of the TrustedIssuer(s) should be refreshed.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Management.VmoClient.TrustedIssuer

## NOTES

## RELATED LINKS
