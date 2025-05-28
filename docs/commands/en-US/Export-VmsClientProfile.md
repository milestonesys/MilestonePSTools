---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Export-VmsClientProfile/
schema: 2.0.0
---

# Export-VmsClientProfile

## SYNOPSIS
Exports one or more smart client profiles to a JSON file.

## SYNTAX

```
Export-VmsClientProfile [-ClientProfile <ClientProfile[]>] [-Path] <String> [-ValueTypeInfo]
 [<CommonParameters>]
```

## DESCRIPTION

The `Export-VmsClientProfile` cmdlet exports one or more smart client profiles
to a JSON file. The resulting file can be imported on the same VMS to restore
lost or changed client profiles to a previous state, or it can be imported on
a different VMS to copy client profiles from one site to another.

When importing profiles from a more advanced VMS tier to a less advanced tier,
such as XProtect Corporate to XProtect Professional+, you may observe errors
during import if a client profile attribute is not present on the less advanced
tier. However, the attributes that do exist on the product tier should be
applied as long as the ErrorAction preference is not set to 'Stop'.

On a default installation of Milestone XProtect Corporate, the size of the JSON
file containing the exported Smart Client Profiles is ~13KB per client profile
without using the `-ValueTypeInfo` switch, or ~50KB per client profile with the
`-ValueTypeInfo` switch. There is no functional benefit to including the
ValueTypeInfo, but it does eliminate ambiguity when you're unsure what the valid
values are for a given client profile attribute.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "SmartClientProfiles"

## EXAMPLES

### Example 1
```powershell
Get-VmsClientProfile | Export-VmsClientProfile -Path .\clientprofiles.json
```

Export all smart client profiles and their attributes to a file named
'clientprofiles.json' in the current folder.

### Example 2
```powershell
Get-VmsClientProfile -DefaultProfile | Export-VmsClientProfile -Path .\defaultprofile.json
```

Export the default smart client profiles and it's attributes to a file named
'defaultprofile.json' in the current folder.

### Example 3
```powershell
Get-VmsClientProfile -DefaultProfile | Export-VmsClientProfile -Path .\defaultprofile.json -ValueTypeInfo
```

Export the default smart client profiles and it's attributes to a file named
'defaultprofile.json' in the current folder. The presence of the `-ValueTypeInfo`
switch means the JSON file will contain information about the valid values for
each attribute.

## PARAMETERS

### -ClientProfile
Specifies a smart client profile. The value can be either a ClientProfile object
as returned by Get-VmsClientProfile, or it can be the name of an existing
client profile.

```yaml
Type: ClientProfile[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
Specifies the file path, including filename, with a .json extension.

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

### -ValueTypeInfo
Include ValueTypeInfo data, if available, for each attribute.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.ClientProfile[]

## OUTPUTS

### None

## NOTES

## RELATED LINKS
