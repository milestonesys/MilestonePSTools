---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsClientProfile/
schema: 2.0.0
---

# New-VmsClientProfile

## SYNOPSIS
Creates a new smart client profile as an identical copy of the default smart client profile.

## SYNTAX

```
New-VmsClientProfile [-Name] <String> [[-Description] <String>] [<CommonParameters>]
```

## DESCRIPTION
The `New-VmsClientProfile` cmdlet creates a new smart client profile as an
identical copy of the default smart client profile, with the exception of a
unique name and optional description.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "SmartClientProfiles"

## EXAMPLES

### Example 1
```powershell
$newProfile = New-VmsClientProfile -Name 'New profile' -Description 'Created using the New-VmsClientProfile cmdlet in the MilestonePSTools PowerShell module.'
$newProfile
```

Creates a new smart client profile with the provided name and description. The
attributes of the profile will match those of the default smart client profile.

## PARAMETERS

### -Description
Specifies an optional description for the smart client profile.

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

### -Name
Specifies a unique name for the smart client profile.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ClientProfile

## NOTES

## RELATED LINKS
