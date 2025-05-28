---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsLoginProvider/
schema: 2.0.0
---

# Remove-VmsLoginProvider

## SYNOPSIS
Removes an external login provider from the VMS.

## SYNTAX

```
Remove-VmsLoginProvider [-LoginProvider] <LoginProvider> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsLoginProvider` cmdlet can be used to remove a configured external
login provider from the VMS. When used without the `-Force` switch, this cmdlet
will return an error if there are any claims associated with any roles, or if
there are any basic user entries associated with the login provider still present
in the VMS configuration.

With the `-Force` switch, the following operations are performed before removing
the login provider: the login provider is disabled to prevent any new logins, all
basic users associated with the login provider are removed, and all claims associated
with the login provider are removed from all roles.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 22.1

## EXAMPLES

### Example 1
```powershell
Get-VmsLoginProvider -Name Auth0 | Remove-VmsLoginProvider -Force
```

The external login provider 'Auth0' is completely removed from the VMS
configuration. Since this command can have a significant impact on business
safety and operations, the default behavior is to request confirmation before
proceeding. To suppress confirmation on any cmdlet implementing `SupportsShouldProcess`
you can add the switch `-Confirm:$false`.

## PARAMETERS

### -Force
Specifies that all related basic users and claims should be removed automatically.

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
Specifies the external login provider to be removed.

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
