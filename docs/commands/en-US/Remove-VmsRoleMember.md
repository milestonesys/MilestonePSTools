---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsRoleMember/
schema: 2.0.0
---

# Remove-VmsRoleMember

## SYNOPSIS
Removes a member from a VMS role.

## SYNTAX

### ByUser (Default)
```
Remove-VmsRoleMember [-Role] <Role[]> [-User] <User[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

### BySid
```
Remove-VmsRoleMember [-Role] <Role[]> [-Sid] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Removes a member from a VMS role.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
foreach ($role in Get-VmsRole) {
    foreach ($member in $role | Get-VmsRoleMember) {
        if ($member.AccountName -eq 'richard' -and $member.IdentityType -eq 'WindowsUser') {
            $role | Remove-VmsRoleMember -User $member -Confirm:$false
        }
    }
}
```

Removes Windows and/or Active Directory users named "richard" from all roles
without confirmation.

## PARAMETERS

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

### -User
Specifies a User object such as is returned by Get-VmsRoleMember.

```yaml
Type: User[]
Parameter Sets: ByUser
Aliases:

Required: True
Position: 1
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

### VideoOS.Platform.ConfigurationItems.Role[]

## OUTPUTS

### None
## NOTES

## RELATED LINKS
