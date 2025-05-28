---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsTrustedIssuer/
schema: 2.0.0
---

# Remove-VmsTrustedIssuer

## SYNOPSIS
Removes an existing TrustedIssuer record.

## SYNTAX

```
Remove-VmsTrustedIssuer [-TrustedIssuer] <TrustedIssuer> [<CommonParameters>]
```

## DESCRIPTION
The Remove-VmsTrustedIssuer command is used to remove or delete an existing TrustedIssuer.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS feature "FederatedSites"
- Requires a VMS connection using a Windows, or Active Directory user account.

## EXAMPLES

### EXAMPLE 1
```
Get-VmsTrustedIssuer -Id 4 | Remove-VmsTrustedIssuer
```

Deletes the TrustedIssuer with Id "4".

### EXAMPLE 2
```
Get-VmsTrustedIssuer | Remove-VmsTrustedIssuer
```

Deletes all TrustedIssuer records.

## PARAMETERS

### -TrustedIssuer
Specifies a TrustedIssuer record returned by the Get-VmsTrustedIssuer command.

```yaml
Type: TrustedIssuer
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### None

## NOTES

## RELATED LINKS
