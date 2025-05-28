---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-OverallSecurity/
schema: 2.0.0
---

# Set-OverallSecurity

## SYNOPSIS

Deprecated. Use `Get-VmsRoleOverallSecurity` and `Set-VmsRoleOverallSecurity`.

## SYNTAX

```
Set-OverallSecurity [-Role <Role>] [-SecurityPermissions <PSObject>] [<CommonParameters>]
```

## DESCRIPTION

Deprecated. Use `Get-VmsRoleOverallSecurity` and `Set-VmsRoleOverallSecurity`.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
# Deprecated.
```

Deprecated.

## PARAMETERS

### -Role

Specifies a role object as is returned by `Get-VmsRole`.

```yaml
Type: Role
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -SecurityPermissions

Specifies new overall security permissions.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

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

## OUTPUTS

### None

## NOTES

## RELATED LINKS
