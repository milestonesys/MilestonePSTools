---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Export-VmsHardware/
schema: 2.0.0
---

# Export-VmsHardware

## SYNOPSIS

Exports hardware device information from an XProtect VMS to either CSV or Excel format.

## SYNTAX

### Path (Default)
```
Export-VmsHardware [-Hardware <Hardware[]>] [-Path] <String> [-DeviceType <String[]>] [-EnableFilter <String>]
 [-Delimiter <Char>] [<CommonParameters>]
```

### LiteralPath
```
Export-VmsHardware [-Hardware <Hardware[]>] -LiteralPath <String> [-DeviceType <String[]>]
 [-EnableFilter <String>] [-Delimiter <Char>] [<CommonParameters>]
```

## DESCRIPTION

The `Export-VmsHardware` cmdlet exports hardware device information from an XProtect VMS to either CSV or Excel format.
The export format is chosen based on the file extension you specify in the `Path` or `LiteralPath` parameter. When
exporting to a file with the `.csv` extension, each row of the CSV file will represent a single device. By default, it
will only export camera device information, but you may specify additional device types with the `DeviceType` parameter.

When exporting to a file with the `.xlsx` extension, a much more detailed export is performed. A worksheet will be
created containing basic hardware information including name, address, credentials, and driver, and additional
worksheets will be created for hardware general settings, ptz settings, cameras, camera general settings, camera stream
settings, and so on.

By default, the command will only export records for _enabled devices_, but you can change that behavior by setting
`EnableFilter` to `All` or `Disabled` to export information for all devices, or only disabled devices respectively.

The output from `Export-VmsHardware` can be used directly with the `Import-VmsHardware` cmdlet to the hardware on a new
management server, or to restore the hardware to the same management server after removign them, or to update settings
on hardware already added to the VMS after modifying the CSV or XLSX files produced by an export.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Export-VmsHardware -Path hardware.csv
```

Gets all hardware available on the VMS and exports the enabled cameras to a CSV file.

### EXAMPLE 2

```powershell
$recorder = Get-VmsRecordingServer | Out-GridView -OutputMode Multiple
$recorder | Get-VmsHardware | Export-VmsHardware -Path hardware.csv
```

This example will prompt for you to select one or more recording servers, and then export all the enabled cameras from
all hardware on those recording servers to a CSV file.

### EXAMPLE 3

```powershell
$recorder = Get-VmsRecordingServer | Out-GridView -OutputMode Multiple
$recorder | Get-VmsHardware | Export-VmsHardware -Path hardware.xlsx -DeviceType Camera, Microphone, Speaker, Metadata, Input, Output
```

This example will prompt for you to select one or more recording servers, and then export all the enabled cameras,
microphones, speakers, metadata, inputs, and outputs on all hardware on those recording servers to a CSV file.

### EXAMPLE 4

```powershell
$recorder = Get-VmsRecordingServer | Out-GridView -OutputMode Multiple
$recorder | Get-VmsHardware | Export-VmsHardware -Path hardware.xlsx -DeviceType Camera, Metadata -EnableFilter All
```

This example will prompt for you to select one or more recording servers, and then export all enabled, and disabled
cameras, and metadata on all hardware on those recording servers to a CSV file.

### EXAMPLE 5

```powershell
$hardware = Get-VmsHardware | Out-GridView -OutputMode Multiple
$hardware | Export-VmsHardware -Path hardware.xlsx
```

This example will prompt for you to select one or more hardware records, and then export all enabled cameras on the
selected hardware to a CSV file.

## PARAMETERS

### -Delimiter

Use this parameter to override the default delimiter ",". This parameter is only used when the imported file is in CSV
format.

```yaml
Type: Char
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceType
Specifies one or more device types to include in the export. By default, only Camera device types are included.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Camera, Microphone, Speaker, Metadata, Input, Output

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableFilter

Specifies whether to return information about enabled object, disabled objects, or all.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: All, Enabled, Disabled

Required: False
Position: Named
Default value: Enabled
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hardware
Specifies one or more hardware devices. Use Get-VmsHardware to retrieve hardware objects.

```yaml
Type: Hardware[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -LiteralPath
Specifies a literal file path without interpreting wildcard characters.

```yaml
Type: String
Parameter Sets: LiteralPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Specifies a path where exported hardware information should be saved. The file extension should be ".csv" or ".xlsx"
depending on whether you prefer to have a basic CSV file export, or a detailed Excel export.

```yaml
Type: String
Parameter Sets: Path
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

### None

## NOTES

The ImportExcel module is used to import and export files with a `.xlsx` extension. If the ImportExcel module is
available on the host computer, it will be loaded from there. If the ImportExcel module cannot be found, an embedded
version of the module will be imported automatically.

## RELATED LINKS
