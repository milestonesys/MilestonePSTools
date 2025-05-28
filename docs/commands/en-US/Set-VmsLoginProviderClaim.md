---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsLoginProviderClaim/
schema: 2.0.0
---

# Set-VmsLoginProviderClaim

## SYNOPSIS
Sets the name or display name of an existing registered claim on a login provider.

## SYNTAX

```
Set-VmsLoginProviderClaim [-Claim] <RegisteredClaim> [[-Name] <String>] [[-DisplayName] <String>] [-PassThru]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsLoginProviderClaim` cmdlet updates the name, or display name of
a claim registered on the specific login provider.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 22.1

## EXAMPLES

### Example 1
```powershell
Get-VmsLoginProviderClaim -LoginProvider 'Auth0' -Name 'vms_role' | Set-VmsLoginProviderClaim -DisplayName 'Roles' -Verbose
```

Sets the display name for the 'vms_role' claim on the 'Auth0' external login
provider to 'Roles'.

## PARAMETERS

### -Claim
Specifies the registered claim to be updated.

```yaml
Type: RegisteredClaim
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -DisplayName
Specifies the desired display name for the specified claim name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the new name for the provided registered claim.

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

### -PassThru
Specifies that the updated registered claim record should be returned to the pipeline.

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

### VideoOS.Platform.ConfigurationItems.RegisteredClaim

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.RegisteredClaim

## NOTES

## RELATED LINKS
