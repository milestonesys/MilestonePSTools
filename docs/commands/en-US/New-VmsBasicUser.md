---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsBasicUser/
schema: 2.0.0
---

# New-VmsBasicUser

## SYNOPSIS
Creates a new Milestone basic user with the specified username and password.

## SYNTAX

```
New-VmsBasicUser [-Name] <String> [-Password] <SecureString> [[-Description] <String>]
 [[-CanChangePassword] <Boolean>] [[-ForcePasswordChange] <Boolean>] [[-Status] <String>] [<CommonParameters>]
```

## DESCRIPTION
The `New-VmsBasicUser` cmdlet creates a new Milestone basic user. Basic users
created within Milestone are unique to the Milestone VMS on which they were
created. They are not compatible with the Milestone Federated Architecture feature
as of VMS versions 2023 R1.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
New-VmsBasicUser -Name 'user1' -Password (Read-Host -Prompt 'Password' -AsSecureString)
```

Prompts for a password and then creates the user 'user1' with the provided password
with the default settings including: Status = Enabled, CanChangePassword = True,
ForcePasswordChange = False.

### Example 2
```powershell
New-VmsBasicUser -Name 'user2' -Password 'P4ssw@rd'
```

Creates the user 'user2' with the password 'P4ssw@rd'. While the Password
parameter is expected to be of type `[securestring]`, it can be provided as a
plain text string as well. It is however recommended not to expose credentials
in a script or terminal.

## PARAMETERS

### -CanChangePassword
Specifies whether the new basic user is allowed to change their own password.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Description
An optional description of the basic user. This is displayed in the management
client and can be be used for any purpose. Sometimes the description is used to
indicate why a user account has been locked or why the account was created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ForcePasswordChange
Specifies that the new user must change their password upon first login.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies the username for the new basic user.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Password
Specifies the password for the new basic user. The password should be provided
as a `[securestring]` but a plain text string will be accepted as well.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Status
Specifies the status for the new basic user account. The default is 'Enabled' and
the other option configurable by the administrator is 'LockedOutByAdmin'. A third
status value exists named 'LockedOutBySystem', but only the VMS can set this
status value. Usually after multiple login failures.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Enabled, LockedOutByAdmin

Required: False
Position: 5
Default value: Enabled
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Security.SecureString

### System.Boolean

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.BasicUser

## NOTES

## RELATED LINKS
