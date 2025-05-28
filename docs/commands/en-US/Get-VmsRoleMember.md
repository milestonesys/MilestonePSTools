---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsRoleMember/
schema: 2.0.0
---

# Get-VmsRoleMember

## SYNOPSIS
Gets the members of the specified VMS role.

## SYNTAX

```
Get-VmsRoleMember [[-Role] <Role[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets the members of the specified VMS role. Members can be local Windows users
and groups, Active Directory users and groups, Milestone Basic Users, users from
a customer-managed external identity provider.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsRole -Name Operators | Get-VmsRoleMember
```

Gets all the members of the role named "Operators".

### Example 2
```powershell
Get-VmsRoleMember -Role "Instructor"
```

Gets all the members of the role named "Instructor".

### Example 3
```powershell
Get-VmsRoleMember
```

Gets all the members of all roles. Note that there is no way to know which role
a role member was returned from as the "User" objects do not have a property on
them to identify the role they were returned from. Users may be a member of
multiple roles, so when you do not provide a role with this cmdlet, you may see
duplicate user entries and this is to be expected.

## PARAMETERS

### -Role
Specifies the role object, or the name of the role.

```yaml
Type: Role[]
Parameter Sets: (All)
Aliases: RoleName

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

### VideoOS.Platform.ConfigurationItems.User
## NOTES

## RELATED LINKS
