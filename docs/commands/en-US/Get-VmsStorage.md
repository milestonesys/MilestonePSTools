---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsStorage/
schema: 2.0.0
---

# Get-VmsStorage

## SYNOPSIS

Gets the Storage objects representing the live recording storages on Milestone XProtect recording servers

## SYNTAX

### FromName (Default)
```
Get-VmsStorage [-RecordingServer <RecordingServer[]>] [-Name <String>] [<CommonParameters>]
```

### FromPath
```
Get-VmsStorage -ItemPath <String> [<CommonParameters>]
```

## DESCRIPTION

Gets the Storage objects representing the live recording storages on Milestone XProtect recording servers

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsRecordingServer -Name 'Recorder 1' | Get-VmsStorage
```

Gets all storage configurations on the recording server named 'Recorder 1

### EXAMPLE 2

```powershell
Get-VmsRecordingServer | Get-VmsStorage -Name 'Local*'
```

Gets all storage configurations on all recording servers where the name begins with 'Local'

### EXAMPLE 3

```powershell
$camera = Get-VmsCamera | Get-Random
Get-VmsStorage -ItemPath $camera.RecordingStorage
```

Gets the storage configuration associated with a random camera retuned by `Get-VmsCamera`.

## PARAMETERS

### -ItemPath

Specifies the Milestone Configuration API path for the storage configuration.
For example, Storage\[eef84b4a-1e7a-4f99-ac5f-671ae76d520b\]
Note: You may pipe a camera object to this cmdlet and the RecordingStorage alias will be used to identify the correct storage configuration

```yaml
Type: String
Parameter Sets: FromPath
Aliases: RecordingStorage, Path

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name

Specifies the name of the storage configuration to return.
Supports wildcards.

```yaml
Type: String
Parameter Sets: FromName
Aliases:

Required: False
Position: Named
Default value: *
Accept pipeline input: False
Accept wildcard characters: True
```

### -RecordingServer

Specifies the Recording Server object from which to return storage configurations

```yaml
Type: RecordingServer[]
Parameter Sets: FromName
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Storage

## NOTES

## RELATED LINKS
