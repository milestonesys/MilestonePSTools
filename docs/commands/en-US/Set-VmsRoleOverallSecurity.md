---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsRoleOverallSecurity/
schema: 2.0.0
---

# Set-VmsRoleOverallSecurity

## SYNOPSIS
Sets the overall security permissions for the given Role and SecurityNamespace.

## SYNTAX

```
Set-VmsRoleOverallSecurity [[-Role] <Role>] [[-SecurityNamespace] <Guid>] [-Permissions] <Hashtable> [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Sets the overall security permissions for the given Role and SecurityNamespace.
the easiest way to build a script to automate permission updates is to retrieve
the permissions of a role that has already been defined, and inspect the names
of the permissions first.

The hashtable provided for the "Permissions" parameter can contain just one
permission, or all available permissions. Only the permissions specified in the
hashtable will be updated on the role.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
$permissions = Get-VmsRoleOverallSecurity -Role 'Operators' -SecurityNamespace Cameras
$permissions.GENERIC_READ = 'Allow'
$permissions.VIEW_LIVE = 'Allow'
$permissions.PLAYBACK = 'Allow'
$permissions.EXPORT = 'Deny'
Set-VmsRoleOverallSecurity -Permissions $permissions
```

Gets the "Cameras" overall security permissions for the role "Operators", and
grants permission to read, view live, and playback all cameras, but denies
permission to export video.

Since the output of Get-VmsRoleOverallSecurity is a hashtable which includes the
"Path" value of the Role, and the SecurityNamespace ID, the Set-VmsRoleOverallSecurity
cmdlet does not need explicit values for the Role and SecurityNamespace parameters.

### Example 2
```powershell
Get-VmsRole -RoleType UserDefined | Set-VmsRoleOverallSecurity -SecurityNamespace Sites -Permissions @{ GENERIC_READ = 'Allow' } -Verbose
```

This example updates the Sites overall security settings to give all user-defined roles "GENERIC_READ" rights on sites, which will make child sites in a Milestone Federated Hierarchy (MFA) visible to members of those roles.

## PARAMETERS

### -Permissions
Specifies a hashtable where the keys match one or more permissions associated
with the specifies SecurityNamespace, and the values are one of "Allow", "Deny",
or "None".

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Role
Specifies the role object, or the name of the role.

```yaml
Type: Role
Parameter Sets: (All)
Aliases: RoleName

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -SecurityNamespace
Specifies the name or ID of an existing security namespace.

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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

### System.String

## OUTPUTS

### System.Collections.Hashtable

## NOTES

## RELATED LINKS
