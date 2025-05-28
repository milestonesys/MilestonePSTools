---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Copy-VmsRole/
schema: 2.0.0
---

# Copy-VmsRole

## SYNOPSIS
Creates a new role based on an existing role.

## SYNTAX

```
Copy-VmsRole -Role <Role> [-NewName] <String> [<CommonParameters>]
```

## DESCRIPTION
The `Copy-VmsRole` cmdlet creates a new role based on an existing role. The new
role will be configured the same as the source role and must have a unique name.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsRole -RoleType Adminstrative | Copy-VmsRole -NewName 'Copy of Administrators role'
```

Creates a new role with the same settings as the default Administrators role.

## PARAMETERS

### -NewName
Specifies a new, unique name for the new role.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Role
Specifies the role object, or the name of the role.

```yaml
Type: Role
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Role

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Role

## NOTES

## RELATED LINKS
