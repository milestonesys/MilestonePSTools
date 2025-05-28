---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsArchiveStorage/
schema: 2.0.0
---

# Get-VmsArchiveStorage

## SYNOPSIS

Gets the ArchiveStorage objects representing the children of a given live storage configuration.

## SYNTAX

```
Get-VmsArchiveStorage [-Storage] <Storage> [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION

Gets the ArchiveStorage objects representing the children of a given live storage configuration.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsRecordingServer -Name 'Recorder 1' | Get-VmsStorage -Name Primary | Get-VmsArchiveStorage
```

Gets all archive storage configurations associated with the live storage configuration named 'Primary', on the recording server named 'Recorder 1'.

### EXAMPLE 2

```powershell
$camera | Get-VmsStorage | Get-VmsArchiveStorage | Sort-Object RetainMinutes -Descending |Select-Object -First 1
```

Gets the oldest archive path associated with $camera.

## PARAMETERS

### -Name

Specifies the name of the storage configuration to return.
Supports wildcards.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: False
Accept wildcard characters: True
```

### -Storage

Specifies a Storage object such as you get from Get-VmsStorage

```yaml
Type: Storage
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ArchiveStorage

## NOTES

## RELATED LINKS
