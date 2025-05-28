---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsViewGroupAcl/
schema: 2.0.0
---

# Get-VmsViewGroupAcl

## SYNOPSIS
Gets the security permissions for one or more roles on a given XProtect Smart Client view group.

## SYNTAX

### FromRole
```
Get-VmsViewGroupAcl -ViewGroup <ViewGroup> [-Role <Role[]>] [<CommonParameters>]
```

### FromRoleId
```
Get-VmsViewGroupAcl -ViewGroup <ViewGroup> -RoleId <Role> [<CommonParameters>]
```

### FromRoleName
```
Get-VmsViewGroupAcl -ViewGroup <ViewGroup> -RoleName <String> [<CommonParameters>]
```

## DESCRIPTION
Top-level view groups defined in the Management Client can be accessed and modified
only if a user's role has permission to that top-level view group. This command
enables you to retrieve the permissions, or "access control list" (ACL), for a
view group. You may modify the permissions and push the changes back to the
Management Server using the Set-VmsViewGroupAcl command.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$viewGroup = Get-VmsViewGroup | Out-GridView -OutputMode Single -Title "Select a View Group"
$roles = Get-VmsRole -RoleType UserDefined
$role = $roles | Out-GridView -OutputMode Single -Title "Select a Role"

$acl = $viewGroup | Get-VmsViewGroupAcl -Role $role
$acl

<# OUTPUT
Role         Path                                            SecurityAttributes
----         ----                                            ------------------
Remote Guard ViewGroup[2B9E3912-3145-4EE8-8C44-244848D1A1C5] {OPERATE, GENERIC_READ...}
#>
```

After ensuring there is an open connection to the Management Server, we prompt
for a view group selection, and a role selection. The ACL for role on the specified
view group is then displayed.

### Example 2
```powershell
$acl.SecurityAttributes

<# OUTPUT
  Name                           Value
  ----                           -----
  OPERATE                        False
  GENERIC_READ                   False
  DELETE                         False
  GENERIC_WRITE                  False
#>

$acl.SecurityAttributes.GENERIC_READ = 'True'
$acl.SecurityAttributes.OPERATE      = 'True'
$acl | Set-VmsViewGroupAcl -WhatIf
```

Continuing from the previous example, the security attributes are expanded so we
can read them all. Then, we change the permissions and push the changes back to
the Management Server using the `Set-VmsViewGroupAcl` cmdlet.

The -WhatIf switch parameter is present, so we see what would happen, without
making any changes. Remove the -WhatIf switch to make permanent changes, and add
the -Verbose switch to see which changes are made.

## PARAMETERS

### -Role
Specifies one or more existing, user-defined roles. If you omit this parameter,
the ACL for every user-defined role will be returned.

```yaml
Type: Role[]
Parameter Sets: FromRole
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RoleId
Specifies the ID of a given role.

```yaml
Type: Role
Parameter Sets: FromRoleId
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RoleName
Specifies the display name of a given role with support for wildcards.

```yaml
Type: String
Parameter Sets: FromRoleName
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ViewGroup
Specifies the view group from which to retrieve the ACL(s).

```yaml
Type: ViewGroup
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.ViewGroup

### VideoOS.Platform.ConfigurationItems.Role[]

### VideoOS.Platform.ConfigurationItems.Role

### System.String

## OUTPUTS

### VmsViewGroupAcl

## NOTES

## RELATED LINKS
