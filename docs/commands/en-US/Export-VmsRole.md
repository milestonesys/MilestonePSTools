---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Export-VmsRole/
schema: 2.0.0
---

# Export-VmsRole

## SYNOPSIS
Exports one or more roles to a JSON file.

## SYNTAX

```
Export-VmsRole [[-Role] <Role[]>] [[-Path] <String>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
The `Export-VmsRole` cmdlet exports one or more roles to a JSON file. The resulting
file can be imported on the same VMS to restore lost or changed roles, or it can
be imported on a different VMS to copy or synchronize roles from one site to another.

When importing roles with references to time profile names, smart client profile
names, or external login provider names that do not exist, the associated role
properties will be skipped and the remaining properties will be imported. If you
later create the missing configuration items and re-import the role(s) with the
`-Force` switch, the roles will be updated accordingly.

On a default installation of Milestone XProtect Corporate, the size of the JSON
file containing the exported roles is ~11KB per role. The file size will vary
significantly depending on the number of role members.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Export-VmsRole -Path .\roles.json
```

Export all roles to a file named 'roles.json' in the current folder.

### Example 2
```powershell
Get-VmsRole -RoleType Adminstrative | Export-VmsRole -Path .\administrators-role.json
```

Export the Administrators role to a file named 'administrators-role.json' in the current folder.

### Example 3
```powershell
$roleDefinitions = Export-VmsRole -PassThru
$roleDefinitions
```

Export all roles to a variable named `$roleDefinitions` instead of exporting the
roles to a file on disk. The variable is the same object or collection of objects
that, when used with the `Path` parameter, is converted to JSON and written to disk.

## PARAMETERS

### -PassThru
Return the role definition(s) to the pipeline instead, or in addition to saving
them to a file on disk.

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

### -Path
Specifies a file path with a .json extension.

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

### -Role
Specifies one or more roles to export. If no role is provided, all roles will be
exported.

```yaml
Type: Role[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Role[]

## OUTPUTS

### System.Management.Automation.PSCustomObject

## NOTES

## RELATED LINKS
