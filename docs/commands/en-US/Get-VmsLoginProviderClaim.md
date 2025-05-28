---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsLoginProviderClaim/
schema: 2.0.0
---

# Get-VmsLoginProviderClaim

## SYNOPSIS
Gets the registered claims associated with the specified login provider.

## SYNTAX

```
Get-VmsLoginProviderClaim [-LoginProvider] <LoginProvider> [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsLoginProviderClaim` cmdlet returns the registered claims associated
with the provided login provider. The claims returned by this cmdlet are the
only claims allowed to be used with roles to determine privileges for users from
the external login provider on the VMS.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 22.1

## EXAMPLES

### Example 1
```powershell
Get-VmsLoginProvider | Get-VmsLoginProviderClaim | Select-Object Name, DisplayName, CaseSensitive
```

Gets all registered claims from all configured login providers an displays the
relevant configuration properties: name, display name, and whether the name of
the claim is case sensitive.

## PARAMETERS

### -LoginProvider
The login provider from which to return the registered claims.

```yaml
Type: LoginProvider
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
Specifies the name of the claim to return from the specified login provider.

```yaml
Type: String
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

### VideoOS.Platform.ConfigurationItems.LoginProvider

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.RegisteredClaim

## NOTES

## RELATED LINKS
