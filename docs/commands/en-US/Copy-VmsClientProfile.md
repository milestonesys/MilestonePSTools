---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Copy-VmsClientProfile/
schema: 2.0.0
---

# Copy-VmsClientProfile

## SYNOPSIS
Creates a copy of an existing client profile with the specified name and description.

## SYNTAX

```
Copy-VmsClientProfile -ClientProfile <ClientProfile> [-NewName] <String> [<CommonParameters>]
```

## DESCRIPTION
The `Copy-VmsClientProfile` cmdlet creates an identical copy of an existing
client profile with the specified name and optional description.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "SmartClientProfiles"

## EXAMPLES

### Example 1
```powershell
$newProfile = Get-VmsClientProfile | Select-Object -First 1 | Copy-VmsClientProfile -NewName 'New Smart Client Profile'
$general = $newProfile | Get-VmsClientProfileAttributes -Namespace General
$general.ApplicationRememberPassword.Value = 'Unavailable'
$general.ApplicationSnapshotPath.Value = 'D:\Snapshots'
$general.ApplicationSnapshotPath.Locked = $true
$newProfile | Set-VmsClientProfileAttributes -Attributes $general
```

Creates a copy of the first Smart Client Profile entry (usually the entry with
the highest priority). Then retrieves the settings defined in the "General"
tab in Management Client. The ability to remember passwords is disabled, and the
snapshot path is locked to "D:\Snapshots".

### Example 2
```powershell
$existingProfile = Get-VmsClientProfile | Select-Object -First 1
$newProfile = $existingProfile | Copy-VmsClientProfile -NewName 'New Smart Client Profile' | Set-VmsClientProfile -Description "Copy of $($existingProfile.Name)" -PassThru
$newProfile
```

Creates a copy of the first Smart Client Profile entry (usually the entry with
the highest priority). Then updates the description to "Copy of [original profile name]".

## PARAMETERS

### -ClientProfile
Specifies a smart client profile. The value can be either a ClientProfile object
as returned by Get-VmsClientProfile, or it can be the name of an existing
client profile.

```yaml
Type: ClientProfile
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -NewName
Specifies the name of the new client profile.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.ClientProfile

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ClientProfile

## NOTES

## RELATED LINKS
