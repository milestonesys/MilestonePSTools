---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsClientProfile/
schema: 2.0.0
---

# Get-VmsClientProfile

## SYNOPSIS
Gets smart client profiles defined in on the VMS.

## SYNTAX

### Name (Default)
```
Get-VmsClientProfile [[-Name] <String>] [<CommonParameters>]
```

### Id
```
Get-VmsClientProfile -Id <Guid> [<CommonParameters>]
```

### DefaultProfile
```
Get-VmsClientProfile [-DefaultProfile] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsClientProfile` cmdlet gets smart client profiles defined in on the
VMS. By default one ClientProfile exists and the `IsDefaultProfile` property of
that ClientProfile will be `$true`. Depending on the VMS version, more client
profiles can be created and assigned as the default client profile for one or
more roles.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "SmartClientProfiles"

## EXAMPLES

### Example 1
```powershell
Get-VmsClientProfile
```

Returns all smart client profiles. The order in which the profiles are returned
should match the order shown in Smart Client. When a user is a member of more than
one role where those roles each have their own default client profile, the user
will end up using the client profile that comes before the others in the list.

### Example 2
```powershell
Get-VmsClientProfile -DefaultProfile
```

Returns the default smart client profile. There should always be only one default
client profile, it it should be the last entry in the list of client profiles as
it will always have the lowest priority.

### Example 3
```powershell
Get-VmsClientProfile -Name 'Remote*'
```

Returns all smart client profiles with a name beginning with the word "Remote".
If no such profiles exist, no value will be returned and no error will be shown
due to the presence of the "*" wildcard character.

### Example 4
```powershell
Get-VmsClientProfile -Name 'Operators'
```

Returns the smart client profile named 'Operators', if it exists. If it does not
exist, an error is returned because the value provided to the `-Name` parameter
does not contain a wildcard character.

### Example 5
```powershell
Get-VmsClientProfile -Id '09325526-64f7-4348-bd40-112f9e17c2e6'
```

Returns the smart client profile with Id '09325526-64f7-4348-bd40-112f9e17c2e6'.
If the provided Id does not match an existing client profile, an error is returned.

## PARAMETERS

### -DefaultProfile
Return only the default client profile.

```yaml
Type: SwitchParameter
Parameter Sets: DefaultProfile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id
Specifies the client profile by Id.

```yaml
Type: Guid
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies the client profile by name, with support for wildcards.

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.Guid

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ClientProfile

## NOTES

## RELATED LINKS
