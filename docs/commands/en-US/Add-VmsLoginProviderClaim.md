---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-VmsLoginProviderClaim/
schema: 2.0.0
---

# Add-VmsLoginProviderClaim

## SYNOPSIS
Add registered claims which will be used to map users with the desired privileges.

## SYNTAX

```
Add-VmsLoginProviderClaim [-LoginProvider] <LoginProvider> [-Name] <String[]> [[-DisplayName] <String[]>]
 [-CaseSensitive] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

The `Add-VmsLoginProviderClaim` registers a specific claim to be used for assigning
users to roles. A wide range of claims may be received after authentication of a
user from an external login provider, but only "registered claims" may be added
to a role for the purpose of granting privileges to users.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 22.1

## EXAMPLES

### Example 1
```powershell
Get-VmsLoginProvider | Add-VmsLoginProviderClaim -Name 'vms_role' -DisplayName 'Role'
```

Adds a registered claim with the name 'vms_role' to all external login providers.
As of VMS version 2023 R1 there can be only one login provider. In the future, if
multiple login providers are supported, this example would add the claim to all
providers.

The display name for the claim is set to 'Role' so this is how it will be displayed
when viewing claims associated with users and roles.

## PARAMETERS

### -CaseSensitive
Specifies that the claim name is case sensitive.

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

### -DisplayName
Specifies an alternate, user-friendly display name for the claim which will be
shown when viewing claims associated with users and roles.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LoginProvider
Specifies the external login provider configuration to which the claim should be
registered.

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
Specifies the name of the claim to be registered. The value should match the
name of a claim present in tokens issued by the external login provider.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
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
