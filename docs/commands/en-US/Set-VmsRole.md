---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsRole/
schema: 2.0.0
---

# Set-VmsRole

## SYNOPSIS
Sets properties of an existing VMS role.

## SYNTAX

```
Set-VmsRole [-Role] <Role[]> [[-Name] <String>] [[-Description] <String>] [-AllowSmartClientLogOn]
 [-AllowMobileClientLogOn] [-AllowWebClientLogOn] [-DualAuthorizationRequired]
 [-MakeUsersAnonymousDuringPTZSession] [[-ClientLogOnTimeProfile] <TimeProfile>]
 [[-DefaultTimeProfile] <TimeProfile>] [[-ClientProfile] <ClientProfile>] [-PassThru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Sets properties of an existing VMS role. Permissions for roles are modified using
other cmdlets such as `Set-VmsRoleOverallSecurity`.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
Set-VmsRole -Role "Operators" -Name "Security" -DualAuthorizationRequired -AllowWebClientLogOn:$false
```

Prompts the user to login to a management server, then changes the "Operators"
role name to "Security" and enables dual authorization on the role, if it was not
already enabled. It also removes permission to logon with the web client if the
privilege had previously been granted.

## PARAMETERS

### -AllowMobileClientLogOn
Specifies that the role is allowed to logon using a mobile client.

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

### -AllowSmartClientLogOn
Specifies that the role is allowed to logon with Smart Client.

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

### -AllowWebClientLogOn
Specifies that the role is allowed to logon with a web browser.

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

### -ClientLogOnTimeProfile
Specifies the time profile within which members of this role are allowed to logon.

```yaml
Type: TimeProfile
Parameter Sets: (All)
Aliases: RoleClientLogOnTimeProfile

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientProfile
Specifies which smart client profile to use with the specified role. Use `Get-VmsClientProfile`
to retrieve smart client profile objects, or enter the client profile by name.

```yaml
Type: ClientProfile
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
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
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Specifies a new description for the role.

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

### -DualAuthorizationRequired
Specifies that members of the role require dual authorization.

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
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies a new name for the role.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Specifies that the modified role should be returned.

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

### -Role
Specifies the role object, or the name of the role.

```yaml
Type: Role[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

### VideoOS.Platform.ConfigurationItems.Role
## NOTES

## RELATED LINKS
