---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-VmsArchiveStorage/
schema: 2.0.0
---

# Add-VmsArchiveStorage

## SYNOPSIS

Adds a new Archive Storage configuration to an existing live recording storage configuration.

## SYNTAX

```
Add-VmsArchiveStorage [-Storage] <Storage> [-Name] <String> [[-Description] <String>] [-Path] <String>
 [[-Retention] <TimeSpan>] [-MaximumSizeMB] <Int32> [-ReduceFramerate] [[-TargetFramerate] <Double>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Adds a new Archive Storage configuration to an existing live recording storage configuration. Note that you cannot add archives with a shorter retention than an existing archive on the same storage configuration.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsRecordingServer | Get-VmsArchiveStorage -Name '90 Day Retention' | Add-VmsArchiveStorage -Name 'Last 80 Days' -Path C:\MediaDatabase\ -Retention (New-Timespan -Days 90) -MaximumSizeMB (10TB/1MB)
```

Adds an archive to every storage configuration on every recording server where the name is '90 Day Retention'.
The storage
and archive names imply that the first 10 days are in the live drive, and the archive contains the last 80 days.
The retention
of the archive is set to 90 days because that value specifies how old the recordings in that container must be before they are
eligible for deleting or archiving to the next archive in the chain.
We use the helpful TB and MB multipliers to specify the
maximum size of 10TB.

## PARAMETERS

### -Description

Specifies the optional description of the storage configuration.

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

### -MaximumSizeMB

Specifies the maximum size for the live storage before data should be archived or deleted.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Specifies the name of the storage configuration.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Specifies the path under which the new storage folder will be created on the Recording Server or UNC
path.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReduceFramerate

Specifies that the framerate should be reduced when taking recordings from the previous live/archive storage area
WARNING: Framerate reduction when the codec is anything besides MJPEG results in keyframes only, which is usually 1 FPS.

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

### -Retention

Specifies the retention, as a `[timespan]`, after which the recordings will be deleted, or archived if
you choose to add an archive storage to the new storage configuration after it is created.

REQUIREMENTS  

- Minimum: 00:01:00, Maximum: 365000.00:00:00

```yaml
Type: TimeSpan
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Storage

Specifies the Recording Server to which the storage configuration should be added.
This should be a
RecordingServer object such as that returned by the Get-VmsRecordingServer cmdlet.

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

### -TargetFramerate

Specifies the desired framerate for recordings stored in this archive storage area.
WARNING: Framerate reduction when the codec is anything besides MJPEG results in keyframes only, which is usually 1 FPS.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: 5
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

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ArchiveStorage

## NOTES

## RELATED LINKS
