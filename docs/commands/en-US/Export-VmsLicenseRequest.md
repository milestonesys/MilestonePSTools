---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Export-VmsLicenseRequest/
schema: 2.0.0
---

# Export-VmsLicenseRequest

## SYNOPSIS

Exports a Milestone XProtect VMS license request file.

## SYNTAX

```
Export-VmsLicenseRequest [-Path] <String> [-Force] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION

Exports a Milestone XProtect VMS license request file which can be uploaded to the My Milestone
portal.
The activated license file can be imported using the Import-VmsLicense function.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.2

## EXAMPLES

### EXAMPLE 1

```powershell
Export-VmsLicenseRequest -Path ~\Downloads\license.lrq -Force
```

Writes a license request file to license.lrq, and overwrites an existing file if it already exists.

## PARAMETERS

### -Force

If a file already exists at the specified path, the file will be overwritten.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru

The new license file should be returned as a FileInfo object.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Specifies a path, including file name, where the license request file should be saved.
Normally
license request files are expected to have a .LRQ extension.

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

## OUTPUTS

### System.IO.FileInfo

### System.IO.FileInfo

Support for license management in Milestone's MIP SDK / Configuration API was introduced in
version 2020 R2.
If the Management Server version is earlier than 2020 R2, this function
will not work.

## NOTES

## RELATED LINKS
