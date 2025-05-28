---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsViewGroupAcl/
schema: 2.0.0
---

# Set-VmsViewGroupAcl

## SYNOPSIS
Sets the security permissions for one or more XProtect Smart Client view groups.

## SYNTAX

```
Set-VmsViewGroupAcl [-ViewGroupAcl] <VmsViewGroupAcl[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The permissions for a role on a given view group can be retrieved using the
`Get-VmsViewGroupAcl` command. After modifying the SecurityAttributes property
of the VmsViewGroupAcl object (see examples), you can pass the ACL to this
command to push the changes to the Management Server.

"GENERIC_READ" enables the right to see the view group in the clients,
Management Client, or through MIP integrations such as MilestonePSTools.

"GENERIC_WRITE" enables the right to edit properties of view groups in
Management Client, or through MIP integrations such as MilestonePSTools.

"DELETE" enables the right to delete view groups in Management Client, or
through MIP integrations such as MilestonePSTools.

"OPERATE" enables the right to modify view groups in XProtect Smart Client such
as to create and delete subgroups and views.

Note: Permissions on private view groups can not be modified.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
$role = Get-VmsRole -Name 'MilestonePSTools' -ErrorAction Ignore
if ($null -eq $role) {
    $role = New-VmsRole -Name 'MilestonePSTools'
}
$viewGroup = New-VmsViewGroup -Name 'MilestonePSTools' -Force
$acl = $viewGroup | Get-VmsViewGroupAcl -Role $role
foreach ($key in @($acl.SecurityAttributes.Keys)) {
    $acl.SecurityAttributes[$key] = 'True'
}
$acl | Set-VmsViewGroupAcl -Verbose

<# OUTPUT
  VERBOSE: Performing the operation "Updating security permissions for role MilestonePSTools" on target "View group "MilestonePSTools"".
  VERBOSE: Performing the operation "Changing OPERATE from False to True" on target "View group "MilestonePSTools"".
  VERBOSE: Performing the operation "Changing GENERIC_READ from False to True" on target "View group "MilestonePSTools"".
  VERBOSE: Performing the operation "Changing DELETE from False to True" on target "View group "MilestonePSTools"".
  VERBOSE: Performing the operation "Changing GENERIC_WRITE from False to True" on target "View group "MilestonePSTools"".
  VERBOSE: Performing the operation "Saving security permission changes for role MilestonePSTools" on target "View group "MilestonePSTools"".
#>
```

After ensuring there is an open connection to the Management Server, we retrieve
a role named "MilestonePSTools" or create one if it doesn't exist. Then we create
a new view group with the same name. If it already exists, no changes are made and
we return the existing view group. Next, we get the ACL for the MilestonePSTools
view group and the matching role, and ensure all security attributes are set to
'True' before updating the permissions for the view group on the Management Server.

With verbose output, we can see each modification made, if any. If no changes need
to be made, you will see only the "Updating securiy permissions..." message.

### Example 2
```powershell
$role = Get-VmsRole -Name 'MilestonePSTools' -ErrorAction Ignore
if ($null -eq $role) {
    $role = New-VmsRole -Name 'MilestonePSTools'
}
foreach ($viewGroup in Get-VmsViewGroup) {
    if ($viewGroup.DisplayName -eq 'Private') {
        # We can not modify private view group permissions
        continue
    }
    $acl = $viewGroup | Get-VmsViewGroupAcl -Role $role
    $acl.SecurityAttributes.GENERIC_READ = 'True'
    $acl.SecurityAttributes.OPERATE = 'True'
    $acl.SecurityAttributes.GENERIC_WRITE = 'False'
    $acl.SecurityAttributes.DELETE = 'False'
    $acl | Set-VmsViewGroupAcl -Verbose
}
```

In this example we get, or create a role named "MilestonePSTools", and give the
role permission to see and modify the contents of all view groups in XProtect
Smart Client. At the same time, we ensure the role cannot rename or delete the
top-level view group.

## PARAMETERS

### -ViewGroupAcl
The modified object returned from calling Get-VmsViewGroupAcl.

```yaml
Type: VmsViewGroupAcl[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
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

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

[View Group Permissions](https://doc.milestonesys.com/latest/en-us/standard_features/sf_mc/sf_ui/mc_roles_security.htm#ViewGrouptabroles)

