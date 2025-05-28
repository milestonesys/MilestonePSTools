---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Save-VmsConnectionProfile/
schema: 2.0.0
---

# Save-VmsConnectionProfile

## SYNOPSIS
Saves the current VMS logon information to a connection profile with the specified name.

## SYNTAX

```
Save-VmsConnectionProfile [[-Name] <String>] [-Force] [<CommonParameters>]
```

## DESCRIPTION
The `Save-VmsConnectionProfile` cmdlet saves the current VMS logon information to a connection profile with the specified
name, or a profile named "default" if no profile name is provided.

When using named connection profiles with MilestonePSTools, the connection details are saved to the current Windows user
profile under `$env:LOCALAPPDATA\MilestonePSTools\credentials.xml` using the `Export-CliXml` cmdlet. If a credential is
provided with `Connect-Vms`, the password is encrypted using Windows Data Protection API with "CurrentUser" scope. This
ensures passwords cannot be decrypted except by the current user on the current computer.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Save-VmsConnectionProfile
```

Saves the current VMS login information to a connection profile named "default". If a profile named "default" already
exists, an error will be returned indicating that you must use the `-Force` switch to indicate that the named profile
should be overwritten.

If no logon session is already established, a Milestone VMS login dialog will be presented, and after successful logon,
the login details will be saved to `$env:LOCALAPPDATA\MilestonePSTools\credentials.xml` under the connection profile name
"default".

### Example 2
```powershell
Save-VmsConnectionProfile -Force
```

Saves the current VMS login information to a connection profile named "default". If a profile named "default" already
exists, it will be updated with the current login information.

If no logon session is already established, a Milestone VMS login dialog will be presented, and after successful logon,
the login details will be saved to `$env:LOCALAPPDATA\MilestonePSTools\credentials.xml` under the connection profile name
"default".

### Example 3
```powershell
Save-VmsConnectionProfile -Name 'MyVMS' -Force
```

Saves the current VMS login information to a connection profile named "MyVMS". If a profile named "MyVMS" already
exists, it will be updated with the current login information.

If no logon session is already established, a Milestone VMS login dialog will be presented, and after successful logon,
the login details will be saved to `$env:LOCALAPPDATA\MilestonePSTools\credentials.xml` under the connection profile name
"default".

## PARAMETERS

### -Force
Specifies that an existing connection profile with the same name should be overwritten.

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
Specifies the name to use to reference the connection profile in the future. The default value is "default".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: default
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### None

## NOTES

## RELATED LINKS
