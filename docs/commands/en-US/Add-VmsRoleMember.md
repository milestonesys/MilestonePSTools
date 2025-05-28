---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-VmsRoleMember/
schema: 2.0.0
---

# Add-VmsRoleMember

## SYNOPSIS
Adds a user or group to the specified role.

## SYNTAX

### ByAccountName (Default)
```
Add-VmsRoleMember [-Role] <Role[]> [-AccountName] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### BySid
```
Add-VmsRoleMember [-Role] <Role[]> [-Sid] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Adds a user or group to the specified role. Members may be Milestone "Basic Users",
external users from a customer-provided identity provider, local Windows users,
or Active Directory users or groups.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Add-VmsRoleMember -Role Operators -AccountName 'security\Ashley'
```

Adds the user "security\Ashley" to the role "Operators". The prefix "security"
could be either a local machine name, or a domain name.

### Example 2
```powershell
$role = New-VmsRole -Name 'Smart Wall Operator' -PassThru
$role | Add-VmsRoleMember -AccountName '[BASIC]\Ashley'
```

Adds the basic user "Ashley" to the role "Smart Wall Operator". The prefix
'[BASIC]' in this down-level logon formatted AccountName ensures that the SID
lookup is performed against the list of basic users configured in the VMS.

## PARAMETERS

### -AccountName
Specifies the account name of the user or group to be added to the role. The
value can be expressed in the following formats: user principal name
(username@domain.ext), down-level logon name (domain\username), or simply
"username". Local Windows or Active Directory groups can be specified the same
way.

Adding members to roles is done by providing the management server with the
desired SID. When the account name is provided without a domain name, the
members of the local machine will be checked first. If no matches are found,
matching Active Directory members will be returned instead.

```yaml
Type: String[]
Parameter Sets: ByAccountName
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Role
Specifies the role object, or the name of the role.

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

### -Sid
Specifies the SID of a user or group.

```yaml
Type: String[]
Parameter Sets: BySid
Aliases:

Required: True
Position: 2
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
Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

## OUTPUTS

### None
## NOTES

A SID is a security identifier and the abbreviation is typically used in the
context of Microsoft operating systems and Active Directory to identify
"objects" like user accounts, groups, computers, and so on.

Basic users in Milestone are defined within the VMS and do not represent, or map
to a Windows or Active Directory object of any kind, but they still have a SID
property. You may notice that these basic user SID's are actually GUIDs or
Globally Unique Identifiers. Presumably this was done to "normalize" all
supported types of users at design time: basic users, local Windows users and
groups, and Active Directory users and groups. By implementing a "SID" property
on basic users, it meant all types of supported users would have a "SID" and
because of this, it would simplify certain operations in the implementation of
security in the product.

## RELATED LINKS
