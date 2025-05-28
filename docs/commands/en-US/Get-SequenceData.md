---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-SequenceData/
schema: 2.0.0
---

# Get-SequenceData

## SYNOPSIS

Get sequence data defining the start and end time of a motion or recording sequence.

## SYNTAX

```
Get-SequenceData [-Path <String>] [[-StartTime] <DateTime>] [[-EndTime] <DateTime>] [[-SequenceType] <String>]
 [-CropToTimeSpan] [-TimeoutSeconds <Int32>] [-PageSize <Int32>] [<CommonParameters>]
```

## DESCRIPTION

Use this command to discover all the the time ranges where recordings and/or motion are present for a device.
This can be useful to generate a report showing the percentage of time a device has been recording, or to look for unusual patterns where there is a much higher or lower than usual percentage of motion/recordings.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
$camera | Get-SequenceData -SequenceType MotionSequence -StartTime ([DateTime]::UtcNow).AddDays(-7)
```

Gets an array of SequenceData objects representing motion sequences beginning or ending within the last 7 days.
The EventSequence property of the SequenceData object contains a StartDateTime and EndDateTime property.

## PARAMETERS

### -CropToTimeSpan

Crop the StartDateTime and EndDateTime to the provided StartTime and EndTime parameters.
By default a sequence with an EndDateTime on or after StartTime, or a StartDateTime on or before EndTime will be returned even if most of the sequence falls outside the bounds of StartTime and EndTime.
For example, if you are recording always, a RecordingSequence may be several days or weeks long, even though you may only be interested in a specific day or hour timespan.
Using this switch can save you some effort when you're generating a report by adding up the duration of all sequences in a given time period.

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

UTC time representing the end of the sequence search period.
Default is "now".

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 8/18/2021 11:10:32 PM
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize

A larger page size may result in a longer wait for the first set of results, but overall shorter processing time.
Default is 1000.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1000
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Specifies an object with a Path property in the format ItemType\[00000000-0000-0000-0000-000000000000\].
This could be a Camera object, or a generic ConfigurationItem object received from Get-ConfigurationItem.

Example: Camera\[724b4f96-6e45-432f-abb2-a71fc87f1c20\]

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SequenceType

Specifies whether to search for recording sequences or motion sequences.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: MotionSequence, RecordingSequence, RecordingWithTriggerSequence

Required: False
Position: 4
Default value: RecordingSequence
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTime

UTC time representing the start of the sequence search period.
Default is 24 hours ago.

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 8/17/2021 11:10:32 PM
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeoutSeconds

Specifies the time in seconds before this command times out while searching for the camera item associated with the given Path.
On a very large system (10k+ devices) this may take several seconds, though it is believed to be a quick search because the Path string defines the device by type and ID.

Default is 10 seconds.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

Specifies an object with a Path property in the format ItemType\[00000000-0000-0000-0000-000000000000\].
This could be a Camera object, or a generic ConfigurationItem object received from Get-ConfigurationItem.

Example: Camera\[724b4f96-6e45-432f-abb2-a71fc87f1c20\]

## OUTPUTS

### VideoOS.Platform.Data.SequenceData

## NOTES

## RELATED LINKS
