---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-VmsRoleClaim/
schema: 2.0.0
---

# Add-VmsRoleClaim

## SYNOPSIS
Adds the name of a registered claim with a given value to one or more roles.

## SYNTAX

```
Add-VmsRoleClaim [-Role] <Role[]> [-LoginProvider] <LoginProvider> [-ClaimName] <String> [-ClaimValue] <String>
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Add-VmsRoleClaim` cmdlet adds a claim name with a given value to one or
more roles. The claim name must already be registered with the associated login
provider. This is done using the `Add-VmsLoginProviderClaim` cmdlet.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 22.1

## EXAMPLES

### Example 1
```powershell
$loginProvider = Get-VmsLoginProvider | Select-Object -First 1
$loginProvider | Add-VmsLoginProviderClaim -Name 'vms_role'
Get-VmsRole -PipelineVariable role | Foreach-Object {
    $role | Add-VmsRoleClaim -LoginProvider $loginProvider -ClaimName 'vms_role' -ClaimValue $role.Name
}
```

The `vms_role` claim is added to the first available login provider, which as of
XProtect VMS versions 2023 R1, will be the only login provider since only one is
supported. After registering the claim with the login provider, an entry is added
for each role with a value matching the name of the role.

## PARAMETERS

### -ClaimName
Specifies the name of the registered claim to add to the specified role.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ClaimValue
The value which should cause users with this claim to be mapped to the specified role.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -LoginProvider
Specifies the login provider for which the claim should be associated.

```yaml
Type: LoginProvider
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Role
Specifies one or more roles to which to add the provided claim and value.

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

### VideoOS.Platform.ConfigurationItems.LoginProvider

### System.String

## OUTPUTS

### None

## NOTES

## RELATED LINKS
