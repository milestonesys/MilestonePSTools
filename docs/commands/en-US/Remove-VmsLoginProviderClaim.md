---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsLoginProviderClaim/
schema: 2.0.0
---

# Remove-VmsLoginProviderClaim

## SYNOPSIS
Removes one, or all registered claims from the specified login provider.

## SYNTAX

### Name
```
Remove-VmsLoginProviderClaim -LoginProvider <LoginProvider> -ClaimName <String> [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### All
```
Remove-VmsLoginProviderClaim -LoginProvider <LoginProvider> [-All] [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsLoginProviderClaim` cmdlet removes one, or all registered claims
from a configured external login provider.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 22.1

## EXAMPLES

### Example 1
```powershell
Get-VmsLoginProvider | Remove-VmsLoginProviderClaim -Force
```

Removes all registered claims from the configured login provider(s). Since the
`-Force` switch is present, the registered claims are first removed from all
roles, as it is not possible to remove a registered claim if that claim has been
associated with a role.

## PARAMETERS

### -All
Specifies that all claims registered with the login provider should be removed.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClaimName
Specifies the literal name of the claim to be removed.

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Specifies that the associated claim(s) should first be removed from all roles
in which it is used.

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

### -LoginProvider
Specifies the login provider from which to remove the registered claim.

```yaml
Type: LoginProvider
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
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

### VideoOS.Platform.ConfigurationItems.LoginProvider

## OUTPUTS

### None

## NOTES

## RELATED LINKS
