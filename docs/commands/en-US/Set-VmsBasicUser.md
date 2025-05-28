---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsBasicUser/
schema: 2.0.0
---

# Set-VmsBasicUser

## SYNOPSIS
Sets the specifies properties on a basic user account.

## SYNTAX

```
Set-VmsBasicUser [-BasicUser] <BasicUser> [[-Password] <SecureString>] [[-Description] <String>]
 [[-CanChangePassword] <Boolean>] [[-ForcePasswordChange] <Boolean>] [[-Status] <String>] [-PassThru] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsBasicUser` is used to update the password, description, status, or
password settings for the specified basic user account.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsBasicUser | Set-VmsBasicUser -Status LockedOutByAdmin -Verbose
```

Gets all basic users, including external users if present, and locks the accounts
until the status is set to 'Enabled' again.

## PARAMETERS

### -BasicUser
Specifies the basic user to be modified. Use `Get-VmsBasicUser` to retrieve basic user records.

```yaml
Type: BasicUser
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -CanChangePassword
If `$true`, the user is allowed to change their own password. This setting applies
only to local Milestone basic users and not external basic users.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Sets the description for the basic user entry.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForcePasswordChange
If `$true` the user must change their password on the next login. This applies
only to local Milestone basic users and not external users.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Specifies that the basic user object should be returned to the pipeline.

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

### -Password
Specifies a new password for a local Milestone basic user account. The password
should be provided as a `[securestring]` but a plain text string may be provided
as well.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status
Specifies the desired status for the basic user.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Enabled, LockedOutByAdmin

Required: False
Position: 5
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

### VideoOS.Platform.ConfigurationItems.BasicUser

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.BasicUser

## NOTES

## RELATED LINKS
