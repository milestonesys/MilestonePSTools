---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsBasicUser/
schema: 2.0.0
---

# Get-VmsBasicUser

## SYNOPSIS

Gets VMS basic user entries.

## SYNTAX

```
Get-VmsBasicUser [[-Name] <String>] [[-Status] <String>] [-External] [<CommonParameters>]
```

## DESCRIPTION

The `Get-VmsBasicUser` cmdlet returns basic user entries from the VMS. Basic
users are users created directly in Milestone with a username and password. A
basic user entry will also be created when users from an external login provider
have authenticated, and have been matched to one or more roles based on the
registered claims and the values of those claims in the token issued for the
user by the external login provider.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsBasicUser
```

Gets all basic user entries present on the management server.

### Example 2
```powershell
Get-VmsBasicUser -Name 'User 54'
```

Gets the basic user named 'User 54', or returns an error if the user does not exist.

### Example 3
```powershell
Get-VmsBasicUser | Where-Object Name -match 'josh'
```

Gets all basic users with a name containing the string 'josh'.

### Example 4
```powershell
Get-VmsBasicUser -External
```

Gets all basic user entries that represent a user from an external login
provider. If no external basic users exist, no value is returned and no error is
emitted.

### Example 5
```powershell
Get-VmsBasicUser -Status LockedOutByAdmin
```

Gets all basic user entries where the user has been locked out by the VMS
administrator.

## PARAMETERS

### -External
Specifies that only users associated with an external login provider should be returned.

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

### -Name
Specifies the literal name of the basic user record to retrieve.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Status
Specifies that only basic users with the provided status should be returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Enabled, LockedOutByAdmin, LockedOutBySystem

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.BasicUser

## NOTES

## RELATED LINKS
