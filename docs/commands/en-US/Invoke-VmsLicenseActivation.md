---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Invoke-VmsLicenseActivation/
schema: 2.0.0
---

# Invoke-VmsLicenseActivation

## SYNOPSIS

Perform an online license activation using My Milestone credentials.

## SYNTAX

```
Invoke-VmsLicenseActivation [-Credential] <PSCredential> [-EnableAutoActivation] [-PassThru]
 [<CommonParameters>]
```

## DESCRIPTION

Perform an online license activation using My Milestone credentials.
Requires that the
Management Server have an internet connection and access to the Milestone Systems license
activation service on HTTPS port 443.

The credentials used for license activation must match a valid My Milestone user with at least
License User privelege and the software license code must already be registered to the company
account.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.2

## EXAMPLES

### EXAMPLE 1

```powershell
Invoke-VmsLicenseActivation -Credential (Get-Credential)
```

Performs an online license activation and does not enable automatic license activation.

## PARAMETERS

### -Credential

Specifies a My Milestone username and password.
The username is usually your e-mail address.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableAutoActivation

Specifies that any system changes requiring license activation should trigger an automatic
license activation using these credentials in the future.
If omitted, automatic license
activation will be disabled if it is currently enabled.

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
Specifies that after a successful license activation, the command should return the output from `Get-VmsLicenseDetails`
which includes information about the number of Activated, InGrace, GraceExpired, and NotLicensed devices.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LicenseDetailChildItem

## NOTES

## RELATED LINKS
