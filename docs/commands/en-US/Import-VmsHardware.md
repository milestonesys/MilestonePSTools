---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Import-VmsHardware/
schema: 2.0.0
---

# Import-VmsHardware

## SYNOPSIS

Imports cameras and other hardware from either a CSV file or an Excel file and adds them to an XProtect recording server.

## SYNTAX

### Path (Default)
```
Import-VmsHardware [-Path] <String[]> [-RecordingServer <RecordingServer>] [-Credential <PSCredential[]>]
 [-UpdateExisting] [-Delimiter <Char>] [<CommonParameters>]
```

### LiteralPath
```
Import-VmsHardware -LiteralPath <String[]> [-RecordingServer <RecordingServer>] [-Credential <PSCredential[]>]
 [-UpdateExisting] [-Delimiter <Char>] [<CommonParameters>]
```

## DESCRIPTION

The `Import-VmsHardware` cmdlet imports cameras and other hardware from either a CSV file or an Excel file and adds them
to an XProtect recording server or optionally _updates_ hardware that has already been added to the VMS. When importing
from a CSV file, each row will describe a camera, or another device type like a microphone, speaker, metadata, input, or
output. For the most basic imports, the only required column in the CSV is the "Address" as the credentials and
destination recording server can be provided using the corresponding parameters.

The most detailed CSV import will look something like the following table:

| DeviceType | Name     | Address       | Channel | UserName | Password | DriverNumber | DriverGroup | RecordingServer | Enabled | HardwareName | StorageName | Coordinates      | DeviceGroups                        |    
|------------|----------|---------------|---------|----------|----------|--------------|-------------|-----------------|---------|--------------|-------------|------------------|-------------------------------------|    
| Camera     | Camera 1 | 192.168.1.101 | 0       | root     | S3cret   | 421          | Universal   | REC1            | True    | Hardware 1   | Storage 1   | 45.417, -122.732 | /Imported cameras;/Portland cameras |    
| Camera     | Camera 2 | 192.168.1.102 | 0       | root     | S3cret   | 806          | AXIS        | REC2            | True    | Hardware 2   | Storage 2   | 55.656, 12.375   | /Imported cameras;/Portland cameras |    
| Camera     | Camera 3 | 192.168.1.102 | 1       | root     | S3cret   | 806          | AXIS        | REC2            | True    | Hardware 2   | Storage 2   | 55.656, 12.375   | /Imported cameras;/Brøndby cameras  |    

Note that the only required information is the device address, and destination recording server. If no credential is
provided in the CSV file, one or more credentials can be provided using the `-Credential` parameter. And if no
credentials are provided, we will attempt to scan each device using the default credential based on the driver.

Driver numbers are available on our supported hardware list, and you can also discover them using the `Get-VmsHardwareDriver`
cmdlet. For example, to list all drivers available on a recorder named "Recorder 1" you can run the command
`Get-VmsRecordingServer -Name 'Recorder 1' | Get-VmsHardwareDriver | Out-GridView`.

If you aren't sure which driver number to use, you can instead provide one or more values in the `DriverGroup` column.
Multiple values should be delimited with a semicolon character, ";". For example, if all cameras are either Axis or
Hanwha, but you're not sure which camera is on which IP address, you can provide a `DriverGroup` value of "Axis;Hanwha"
for all records and we will do a hardware scan limited to the drivers under the AXIS and Hanwha driver groups.

If you don't provide a driver number or driver group, we will perform a hardware scan using all available drivers. That
can take more time, but the necessary time may be reduced thanks to an "Express Scan" performed on each recording server
which can more quickly identify hardware as long as it responds to the "Express Scan" scanning method.

An even more detailed import can be performed from an Excel file with an `.xlsx` extension. The format of the file is
too complex to describe here or expect anyone to produce by hand. Our suggestion is to perform an export to a `.xlsx`
file after either importing using a CSV file, or manually adding and configuring some cameras. The resulting `.xlsx`
file can be modified and then imported to add or update hardware.

The advantage of importing from an Excel file is that you can make extremely detailed configuration changes in the Excel
file, including enabling hardware events, changing general settings and stream settings, and then import those changes.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Import-VmsHardware -Path hardware.csv
```

Imports hardware from `hardware.csv`. Since the RecordingServer parameter was not specified, the RecordingServer column
must be specified for each row in the CSV file, and the value should be the display name of the destination recording
server.

### EXAMPLE 2

```powershell
$recorder = Get-VmsRecordingServer -Name 'Recorder 1'
$credentials = 1..3 | ForEach-Object { Get-Credential -Message "Credential $_" }

$splat = @{
    Path            = 'hardware.csv'
    RecordingServer = $recorder
    Credential      = $credentials
}
Import-VmsHardware @splat
```

Imports hardware from `hardware.csv`. Since the RecordingServer parameter is specified as a parameter, all records in
the CSV file will be imported to the recording server named "Recorder 1". The user is prompted to enter three different
credentials, and these credentials will be combined with the usernames and passwords in the CSV file, if present, to be
used during the hardware scanning phase. This is useful when you're not use which password each device is using but you
know it's one of a handful of options. PowerShell's "splatting" feature is used here to reduce the width of the example.

### EXAMPLE 3

```powershell
Import-VmsHardware -Path hardware.csv -UpdateExisting
```

Imports hardware from `hardware.csv`. Any hardware that has already been added to the target recording server will be
updated based on the content of the CSV.

### EXAMPLE 4

```powershell
Import-VmsHardware -Path hardware.csv -UpdateExisting
```

Imports hardware from `hardware.csv`. Any hardware that has already been added to the target recording server will be
updated based on the content of the CSV.

### EXAMPLE 5

```powershell
Import-VmsHardware -Path hardware.xlsx -UpdateExisting
```

Imports hardware from `hardware.xlsx`. Any hardware that has already been added to the target recording server will be
updated based on the content of the CSV. Based on the presence and content of various worksheets in the Excel workbook,
the import may update a small number of settings, or it may update nearly every property available under every hardware
device in the workbook.

## PARAMETERS

### -Credential
Optionally specifies one or more credentials to try. The first credential to try will always be the username and
password for each hardware device in the incoming file. If no credentials are present in the file, or you want to try
multiple credentials for all devices, these credentials will be tried until one has succeeded, or all have failed to
authenticate with the hardware.

```yaml
Type: PSCredential[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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

### -LiteralPath
Specifies a path to a CSV or XLSX file. The value of LiteralPath is used exactly as it's typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation marks tell PowerShell to not interpret any characters as escape sequences.

```yaml
Type: String[]
Parameter Sets: LiteralPath
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path

Specifies a path to a CSV or XLSX file.

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -RecordingServer

Specifies the recording server on which the hardware should be added or updated. This parameter will override the value
in the RecordingServer column of the incoming CSV or XLSX file if present.

```yaml
Type: RecordingServer
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateExisting
Specifies that any hardware that has already been added should be updated based on the settings in the incoming file.
The default behavior is to skip any hardware that already exists on the destination recording server.

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

## OUTPUTS

## NOTES

The ImportExcel module is used to import and export files with a `.xlsx` extension. If the ImportExcel module is
available on the host computer, it will be loaded from there. If the ImportExcel module cannot be found, an embedded
version of the module will be imported automatically.

## RELATED LINKS
