---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsCameraReport/
schema: 2.0.0
---

# Get-VmsCameraReport

## SYNOPSIS

Gets a detailed report at the camera device level for all cameras added to the current Milestone XProtect VMS site.

## SYNTAX

```
Get-VmsCameraReport [[-RecordingServer] <RecordingServer[]>] [-IncludePlainTextPasswords]
 [-IncludeRetentionInfo] [-IncludeRecordingStats] [-IncludeSnapshots] [[-SnapshotTimeoutMS] <Int32>]
 [[-SnapshotHeight] <Int32>] [[-EnableFilter] <String>] [<CommonParameters>]
```

## DESCRIPTION

Returns a report with detailed camera status and configuration information.
A popular use of a report like this is
to verify configuration properties are consistent between cameras, or to check that the desired video retention is
being reached for all cameras.
The report is returned as an array of \[PSCustomObject\]'s which you can then process
in your script, or pipe directly to a CSV file.
See the examples for inspiration.

For additional information about the output, including detailed column
information, see the about_Get-VmsCameraReport help topic by using
"Get-Help about_Get-VmsCameraReport".

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Connect-Vms -ShowDialog -AcceptEula
Get-VmsCameraReport -RecordingServer (Get-VmsRecordingServer | Out-GridView -OutputMode Multiple) | Out-GridView
```

Presents a gridview dialog for you to select one or more recording servers, then generates a camera report for cameras on those recording servers, and presents the results in gridview.

### EXAMPLE 2

```powershell
Connect-Vms -ShowDialog -AcceptEula
$fileName = "camera-report_$((Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')).csv"
$filePath = Join-Path -Path "~\Desktop" -ChildPath $fileName
Get-VmsCameraReport -IncludeRetentionInfo -IncludeRecordingStats | Export-Csv -Path $filePath
```

Creates a camera report with video retention information and recording statistics, and saves the results to the current user's desktop with a timestamp in the file name.

## PARAMETERS

### -EnableFilter
Specifies which devices to include in the report. Default is to include only enabled devices.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: All, Disabled, Enabled

Required: False
Position: 3
Default value: Enabled
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludePlainTextPasswords
Specifies that a plain text password should be included in the report for each device.

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

### -IncludeRecordingStats
Specifies that the % of time each camera has been recording over the last 7 days should be included in the report. Note that including this may result in a long time to complete the report.

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

### -IncludeRetentionInfo
Specifies that the report should timestamps for the first and last recorded images, and whether each camera meets the configured retention settings for the storage configuration.

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

### -IncludeSnapshots
Specifies that a bitmap object should be included in the results of the report. You must decide how to handle this snapshot yourself. If you try to export to CSV with snapshots, the Snapshot column will contain only the name of the bitmap type.

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

### -RecordingServer
Specifies one or more RecordingServer objects such as returned by Get-VmsRecordingServer. Omit this parameter and the report will include cameras from all recording servers on the current site.

```yaml
Type: RecordingServer[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SnapshotHeight
Specifies the image height for snapshots if included. Default is 300 pixels in height. Aspect ratio will be maintained.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 300
Accept pipeline input: False
Accept wildcard characters: False
```

### -SnapshotTimeoutMS
Specifies the number of milliseconds to wait for a live image to arrive when
used with IncludeSnapshots. The default timeout for Get-VmsCameraReport is 10000
or 10 seconds, though the default timeout for Get-Snapshot is 2000 or 2 seconds.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 10000
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
