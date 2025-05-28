---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-VmsConnectionProfile/
schema: 2.0.0
---

# Remove-VmsConnectionProfile

## SYNOPSIS
Removes the named connection profile, or all connection profiles.

## SYNTAX

### Name
```
Remove-VmsConnectionProfile [-Name] <String[]> [<CommonParameters>]
```

### All
```
Remove-VmsConnectionProfile [-All] [<CommonParameters>]
```

## DESCRIPTION
The `Remove-VmsConnectionProfile` cmdlet removes the named connection profile, or all connection profiles.

When using named connection profiles with MilestonePSTools, the connection details are saved to the current Windows user
profile under `$env:LOCALAPPDATA\MilestonePSTools\credentials.xml` using the `Export-CliXml` cmdlet. If a credential is
provided with `Connect-Vms`, the password is encrypted using Windows Data Protection API with "CurrentUser" scope. This
ensures passwords cannot be decrypted except by the current user on the current computer.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1
```powershell
Remove-VmsConnectionProfile
```

Deletes the connection profile information for the profile named "default".

### Example 2
```powershell
Remove-VmsConnectionProfile -Name "MyVMS"
```

Deletes the connection profile information for the profile named "MyVMS".

### Example 3
```powershell
Remove-VmsConnectionProfile -Name "MyVMS", "MyOtherVMS"
```

Deletes the connection profile information for the profiles named "MyVMS" and "MyOtherVMS".

### Example 4
```powershell
Remove-VmsConnectionProfile -All
```

Deletes the connection profile information for all connection profiles saved in the current Windows user profile.

## PARAMETERS

### -All
Specifies that all connection profiles saved in the current Windows user profile should be removed.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the name of the connection profile to remove in the current Windows user profile.

```yaml
Type: String[]
Parameter Sets: Name
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### None

## NOTES

## RELATED LINKS
