---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsRole/
schema: 2.0.0
---

# New-VmsRole

## SYNOPSIS
Creates a new role on the connected VMS.

## SYNTAX

```
New-VmsRole [-Name] <String> [[-Description] <String>] [-AllowSmartClientLogOn] [-AllowMobileClientLogOn]
 [-AllowWebClientLogOn] [-DualAuthorizationRequired] [-MakeUsersAnonymousDuringPTZSession]
 [[-ClientLogOnTimeProfile] <TimeProfile>] [[-DefaultTimeProfile] <TimeProfile>]
 [[-ClientProfile] <ClientProfile>] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new role and matching view group on the connected VMS. Permissions are
associated with roles, and roles can have any number of users and groups, or
"members".

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Connect-Vms -AcceptEula
New-VmsRole -Name "My new role" -AllowMobileClientLogOn -AllowSmartClientLogOn -AllowWebClientLogOn
```

Logs in to a management server, then creates a new role named "My new role" with
permission to logon to the mobile client, smart client, and web client. Note
that the role does not yet have any members, and it has not been assigned
permissions to any cameras.

## PARAMETERS

### -AllowMobileClientLogOn
Allow members of this role to logon using a mobile client.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AllowSmartClientLogOn
Allow members of this role to logon using Smart Client.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AllowWebClientLogOn
Allow members of this role to logon using a web browser.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ClientLogOnTimeProfile
Specifies the time profile within which members of this role are allowed to logon.

```yaml
Type: TimeProfile
Parameter Sets: (All)
Aliases: RoleClientLogOnTimeProfile

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ClientProfile
Specifies which smart client profile to use with the new role. Use `Get-VmsClientProfile`
to retrieve smart client profile objects, or enter the client profile by name.

```yaml
Type: ClientProfile
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DefaultTimeProfile
Specifies the default time profile to use for permissions such as when members
are allowed to play back recordings.

```yaml
Type: TimeProfile
Parameter Sets: (All)
Aliases: RoleDefaultTimeProfile

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Description
Specifies an optional description for the role.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DualAuthorizationRequired
Specifies that dual authorization is required for members of the role.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MakeUsersAnonymousDuringPTZSession
Specifies that PTZ operations should not be attributed to a specific user for
members of the role.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies a name for the new role.

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

### -PassThru
Specifies that the new role should be returned to the caller. Normal behavior
for a "New-*" cmdlet is to return the new item by default. However, when
creating a large number of roles, the added time to make an extra API call to
retrieve the new role, or to enumerate through the cached role collection to
find it may not be preferred.

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

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Role

## NOTES

When you create a new role with the `New-VmsRole` cmdlet, a new view group is created with the same name. This is a part
of the MIP SDK and the Management Server APIs, and matches the experience when creating roles in Management Client.
These automatically-created view groups are not required and can be deleted at any time using the `Remove-VmsViewGroup`
cmdlet. For example `Get-VmsViewGroup -Name 'viewgroup name' | Remove-VmsViewGroup -Recurse`.

## RELATED LINKS
