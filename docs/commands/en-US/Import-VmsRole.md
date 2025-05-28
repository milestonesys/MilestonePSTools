---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Import-VmsRole/
schema: 2.0.0
---

# Import-VmsRole

## SYNOPSIS
Imports one or more roles from a json-formatted file on disk.

## SYNTAX

### Path (Default)
```
Import-VmsRole -Path <String> [-Force] [-RemoveUndefinedClaims] [-RemoveUndefinedUsers] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### InputObject
```
Import-VmsRole -InputObject <Object[]> [-Force] [-RemoveUndefinedClaims] [-RemoveUndefinedUsers] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Import-VmsRole` cmdlet imports one or more roles from a json-formatted file
on disk. The format of the file should match the format produced by the
`Export-VmsRole` cmdlet.

By using `Export-VmsRole` and `Import-VmsRole` you can import new roles or update
existing roles with the same name(s). The roles can be exported from one
Milestone VMS and imported into another Milestone VMS which can save time when
managing multiple sites with the same or similar role definitions.

If the roles to be imported include basic users as members, a matching basic user
will be created if necessary. These auto-created basic user accounts will have
string, random 30-character passwords, and they will be disabled. To use these
basic user accounts, a VMS Administrator will need to reset the passwords and
enable the accounts.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Export-VmsRole -Path .\roles.json
# Remove one or more roles or change settings on one or more roles.
Import-VmsRole -Path .\roles.json -Force -Verbose
```

Export all roles, and then import them again. The `Force` switch is
required in this case because the roles may already exist. If any roles were
modified or removed between the export and the import, then the missing roles
will be recreated, and the existing roles will be updated to match the content
of the export.

## PARAMETERS

### -Force
Specified when one or more roles to be imported may already exist, and the
settings of existing roles should be updated.

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

### -InputObject
Specifies one or more objects of type `[pscustomobject]` from a previous call to
`Export-VmsRole -PassThru`.

```yaml
Type: Object[]
Parameter Sets: InputObject
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Specifies the file path, including filename, with a .json extension.

```yaml
Type: String
Parameter Sets: Path
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveUndefinedClaims
Specifies that any external login provider claims present on existing roles that
are not defined in the source of the import should be removed from the existing
roles. If omitted, claims can be _added_ to existing roles if the `-Force` switch
is present, but no claims can be _removed_.

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

### -RemoveUndefinedUsers
Specifies that any Windows, Active Directory, or Basic user role members present
on existing roles that are not defined in the source of the import should be
removed from the existing roles. If omitted, role members can be _added_ to
existing roles if the `-Force` switch is present, but no users can be _removed_.

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

### System.Object[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Role

## NOTES

## RELATED LINKS
