---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsClientProfile/
schema: 2.0.0
---

# Set-VmsClientProfile

## SYNOPSIS
Updates the name, description, or priority of an existing smart client profile.

## SYNTAX

```
Set-VmsClientProfile [-ClientProfile] <ClientProfile> [[-Name] <String>] [[-Description] <String>]
 [[-Priority] <Int32>] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsClientProfile` cmdlet updates the name, description, or priority of
an existing smart client profile. The priority of a client profile is not available
as a property on the `ClientProfile` object, but the order in which the profiles
are returned by `Get-VmsClientProfile` should reflect the same order and priority
shown in Management Client.

If a profile should have the highest, most "important" priority and be assigned
first when a user is a member of multiple roles with different smart client
profiles, that profile should be given a low priority number with "1" as the
lowest value. By assigning a priority of "1" to a client profile, that profile
should move to the top of the smart client profile list in Management Client.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "SmartClientProfiles"

## EXAMPLES

### Example 1
```powershell
$clientProfiles = Get-VmsClientProfile -DefaultProfile:$false
$clientProfiles | Set-VmsClientProfile -Priority (Get-Random -Minimum 1 -Maximum ($clientProfiles.Count + 1)) -Verbose -WhatIf
```

Randomly re-prioritize smart client profiles.

### Example 2
```powershell
Import-VmsClientProfile -Path .\clientprofile.json | Set-VmsClientProfile -Priority 1 -Description "Imported with Import-VmsClientProfile."
```

Import one or more profiles from a local `clientprofile.json` file. If more than
one client profile are defined in the file, they will all be imported and they
will all be given the same description. However, only the last profile in the
file will have priority "1". Each time a profile is given a new priority, it is
moved up or down the list as needed.

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
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Description
Specifies an optional description.

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

### -Name
Specifies a new, unique name for the smart client profile.

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
Specifies that the updated client profile should be returned to the pipeline.

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

### -Priority
Specifies a new priority from 1 to `[int]::MaxValue`.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

### VideoOS.Platform.ConfigurationItems.ClientProfile

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ClientProfile

## NOTES

## RELATED LINKS
