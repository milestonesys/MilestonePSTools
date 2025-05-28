---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Import-VmsClientProfile/
schema: 2.0.0
---

# Import-VmsClientProfile

## SYNOPSIS
Imports one or more smart client profiles from a json-formatted file on disk.

## SYNTAX

```
Import-VmsClientProfile [-Path] <String> [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Import-VmsClientProfile` cmdlet imports one or more smart client profiles
from a json-formatted file on disk. The format of the file should match the format
produced by the `Export-VmsClientProfile` cmdlet.

By using `Export-VmsClientProfile` and `Import-VmsClientProfile` you can import
new smart client profiles or update existing profiles with the same name(s). The
profiles can be exported from one Milestone VMS and imported into another
Milestone VMS which can save time when managing multiple sites with the same or
similar smart client profile requirements.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "SmartClientProfiles"

## EXAMPLES

### Example 1
```powershell
Export-VmsClientProfile -Path .\clientprofiles.json
# Remove one or more client profiles or change settings on one or more profiles.
Import-VmsClientProfile -Path .\clientprofiles.json -Force
```

Export all client profiles, and then import them again. The `Force` switch is
required in this case because the profiles may already exist. If any profiles
were modified or removed between the export and the import, then the missing
client profiles will be recreated, and the existing client profiles will be
updated to match the content of the export.

## PARAMETERS

### -Force
Specified when one or more client profiles to be imported may already exist, and
the settings of existing client profiles should be updated.

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

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ClientProfile

## NOTES

## RELATED LINKS
