---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsRoleClaim/
schema: 2.0.0
---

# Remove-VmsRoleClaim

## SYNOPSIS
Removes one or more claims from the specified role.

## SYNTAX

```
Remove-VmsRoleClaim [-Role] <Role[]> [[-LoginProvider] <LoginProvider>] [-ClaimName] <String[]>
 [-ClaimValue <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsRoleClaim` cmdlet removes the specified claim(s) from the specified
role(s). The claims must be identified by name and the `Get-VmsRoleClaim` cmdlet
can be used to retrieve a list of claims and values assigned to the role.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 22.1

## EXAMPLES

### Example 1
```powershell
Get-VmsRole | Remove-VmsRoleClaim -ClaimName 'vms_role' -ErrorAction SilentlyContinue -Verbose
```

Removes the claim named 'vms_role' from all roles where it has been added. The
`-ErrorAction SilentlyContinue` will suppress errors where that claim is not found
on the role.

## PARAMETERS

### -ClaimName
Specifies one or more literal claim names to be removed.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ClaimValue
Specifies the claim value for claims that should be removed by this command.

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

### -LoginProvider
Specifies the login provider associated with the claims to be removed from the role. Current VMS versions support only
one external login provider, but future versions may support more than one.

```yaml
Type: LoginProvider
Parameter Sets: (All)
Aliases: ClaimProvider

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Role
Specifies the role from which to remove the claim(s).

```yaml
Type: Role[]
Parameter Sets: (All)
Aliases: RoleName

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

### VideoOS.Platform.ConfigurationItems.Role[]

### System.String[]

## OUTPUTS

### None

## NOTES

## RELATED LINKS
