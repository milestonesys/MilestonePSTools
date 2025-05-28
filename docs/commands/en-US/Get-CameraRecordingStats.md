---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-CameraRecordingStats/
schema: 2.0.0
---

# Get-CameraRecordingStats

## SYNOPSIS

Get statistics on the recordings of one or more cameras including the number of recording or motion
sequence, the amount of time in the given time period with recordings or motion, and the percent of time
in the given time period with recordings or motion.

## SYNTAX

```
Get-CameraRecordingStats [-Id] <Guid[]> [[-StartTime] <DateTime>] [[-EndTime] <DateTime>]
 [[-SequenceType] <String>] [-AsHashTable] [[-RunspacePool] <RunspacePool>] [<CommonParameters>]
```

## DESCRIPTION

The `Get-CameraRecordingStats` cmdlet gets statistics on the recordings of one or more cameras, including the
number of recording or motion sequences, the amount of time in the given time period with recordings or
motion, and the percent of time in the given time period with recordings or motion.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Select-Camera | Get-CameraRecordingStats
```

Opens a camera selection dialog and the selected camera will be sent to Get-CameraRecordingStats.
The result will
be a PSCustomObject with the DeviceID and a nested PSCustomObject under the RecordingStats property name.

### EXAMPLE 2

```powershell
$cam = Get-VmsCamera | Select-Object -First 1
$cam | Get-CameraRecordingStats -StartTime (Get-Date).AddDays(-3) -EndTime (Get-Date).AddDays(-2) -SequenceType MotionSequence
```

Saves the first camera from `Get-VmsCamera` to $cam and then gets the recording statistics of all motions sequences between 3
days ago and 2 days ago. The result will be a PSCustomObject with the DeviceID and a nested PSCustomObject under the
RecordingStats property name.

## PARAMETERS

### -AsHashTable

Specifies that the output should be provided in a complete hashtable instead of one pscustomobject value at a time

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

### -EndTime

Specifies the timestamp marking the end of the time period for which to retrieve recording statistics.
The default is 12:00am of the current day.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Get-Date).Date
Accept pipeline input: False
Accept wildcard characters: False
```

### -Id

Specifies the Id's of cameras for which to retrieve recording statistics

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RunspacePool

Specifies the runspacepool to use.
If no runspacepool is provided, one will be created.

```yaml
Type: RunspacePool
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SequenceType

Specifies the type of sequence to get statistics on.
Default is RecordingSequence.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: RecordingSequence, MotionSequence

Required: False
Position: 3
Default value: RecordingSequence
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTime

Specifies the timestamp from which to start retrieving recording statistics.
Default is 7 days prior to 12:00am of the current day.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-Date).Date.AddDays(-7)
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
