---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsConnectionProfile/
schema: 2.0.0
---

# Get-VmsConnectionProfile

## SYNOPSIS
Gets the saved VMS connection profile, or all saved VMS connection profiles.

## SYNTAX

### Name (Default)
```
Get-VmsConnectionProfile [[-Name] <String>] [<CommonParameters>]
```

### All
```
Get-VmsConnectionProfile [-All] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsConnectionProfile` cmdlet returns the properties for a named VMS connection profile previously saved using
the `Connect-Vms` cmdlet, or the `Save-VmsConnectionProfile` cmdlet.

When using named connection profiles with MilestonePSTools, the connection details are saved to the current Windows user
profile under `$env:LOCALAPPDATA\MilestonePSTools\credentials.xml` using the `Export-CliXml` cmdlet. If a credential is
provided with `Connect-Vms`, the password is encrypted using Windows Data Protection API with "CurrentUser" scope. This
ensures passwords cannot be decrypted except by the current user on the current computer.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1
```powershell
Get-VmsConnectionProfile
```

Gets the VMS connection profile information for the profile named 'default'.

### Example 2
```powershell
Get-VmsConnectionProfile -Name 'default'
```

Gets the VMS connection profile information for the profile named 'default'.

### Example 3
```powershell
Get-VmsConnectionProfile -Name 'management1'
```

Gets the VMS connection profile information for the profile named 'management1'.

### Example 4
```powershell
Get-VmsConnectionProfile -All
```

Gets a list of all saved VMS connection profiles available to the currently logged on Windows user.

## PARAMETERS

### -All
Return all saved connection profiles.

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
Specifies the name of the connection profile to return.

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: False
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

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
