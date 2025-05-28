---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsLoginProvider/
schema: 2.0.0
---

# Get-VmsLoginProvider

## SYNOPSIS
Gets the configured external login provider(s).

## SYNTAX

```
Get-VmsLoginProvider [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsLoginProvider` cmdlet gets the configured external login provider. As
of XProtect VMS versions 2023 R1 there can be only one external login provider.
In the future, it may be possible to have more than one external login provider,
and this cmdlet should be capable of returning one, or more, or all login
providers configured on the VMS.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 22.1

## EXAMPLES

### Example 1
```powershell
Get-VmsLoginProvider
```

Gets all configured login providers.

### Example 2
```powershell
Get-VmsLoginProvider -Name Auth0
```

Gets the login provider Auth0, or results in an error if no matching login
provider is found in the VMS configuration.

## PARAMETERS

### -Name
Specifies the literal name of an existing login provider entry.

```yaml
Type: String
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

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LoginProvider

## NOTES

## RELATED LINKS
