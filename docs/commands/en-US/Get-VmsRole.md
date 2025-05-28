---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsRole/
schema: 2.0.0
---

# Get-VmsRole

## SYNOPSIS
Gets one or more of the roles already configured in the VMS.

## SYNTAX

### ByName (Default)
```
Get-VmsRole [[-Name] <String>] [-RoleType <String>] [<CommonParameters>]
```

### ById
```
Get-VmsRole [-Id <Guid>] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsRole` cmdlet gets roles configured in the VMS. Users and groups can
be a member of one or more roles, and permissions are granted (or denied) to a
role.

Permissions for a role are divided into two categories: overall security, and
item-level security. For example, a role can be granted "Allow" for
"GENERIC_READ", "VIEW_LIVE", and "PLAYBACK" for all cameras using overall
security. Alternatively, a role can be granted those permissions for only a
select set of cameras.

Permissions can be mixed as well. For example, if you want all members of a role
to have permission to view live video from all cameras, you can set "GENERIC_READ"
and "VIEW_LIVE" to "Allow" under overall security, and then grant playback
permission to a subset of cameras.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsRole
```

Gets all roles defined in the VMS, including the default Administrators role.

### Example 2
```powershell
Get-VmsRole -Name Operators
```

Gets the role named "Operators" if it exists, or returns an error if the role could not be found.

### Example 3
```powershell
Get-VmsRole -RoleType UserDefined
```

Gets all user-defined roles. This is useful when checking/changing permissions for many roles since it is invalid to change
permissions for the Administrator role.

## PARAMETERS

### -Id
Specifies the `[guid]` of an existing role.

```yaml
Type: Guid
Parameter Sets: ById
Aliases: RoleId

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies the name of a role with support for wildcards.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RoleType
Specifies the type of role to return: Administrative, or UserDefined. Please
note that the typo on "Adminstrative" intentionally matches the typo for the
RoleType property in MIP SDK.

```yaml
Type: String
Parameter Sets: ByName
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

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Role

## NOTES

## RELATED LINKS
