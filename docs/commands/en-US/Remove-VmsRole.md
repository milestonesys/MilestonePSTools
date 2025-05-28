---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsRole/
schema: 2.0.0
---

# Remove-VmsRole

## SYNOPSIS
Removes the specified role from the management server.

## SYNTAX

### ByName (Default)
```
Remove-VmsRole [-Role] <Role> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### ById
```
Remove-VmsRole -Id <Guid> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes the specified role from the management server.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsRole -Name 'MilestonePSTools' | Remove-VmsRole -WhatIf
```

If the "WhatIf" parameter were removed, this would remove the role named
"MilestonePSTools" if it exists.

## PARAMETERS

### -Id
Specifies the unique ID of the role.

```yaml
Type: Guid
Parameter Sets: ById
Aliases: RoleId

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Role
Specifies the role object as is returned by Get-VmsRole, or the role name.

```yaml
Type: Role
Parameter Sets: ByName
Aliases: RoleName, Name

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### VideoOS.Platform.ConfigurationItems.Role

### System.Guid

## OUTPUTS

### None
## NOTES

## RELATED LINKS
