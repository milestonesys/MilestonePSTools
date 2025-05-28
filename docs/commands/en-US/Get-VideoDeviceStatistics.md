---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VideoDeviceStatistics/
schema: 2.0.0
---

# Get-VideoDeviceStatistics

## SYNOPSIS

Gets the camera device statistics including used storage space, and the properties of each video stream being retrieved from the camera

## SYNTAX

```
Get-VideoDeviceStatistics [[-RecordingServerId] <Guid[]>] [-AsHashTable] [[-RunspacePool] <RunspacePool>]
 [<CommonParameters>]
```

## DESCRIPTION

Uses the RecorderStatusService2 client to call GetVideoDeviceStatistics and receive the current video device statistics
of all cameras, or filtered by Recording Server.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsRecordingServer -Name 'My Recording Server' | Get-VideoDeviceStatistics
```

Gets the video statistics of all cameras on the Recording Server named 'My Recording Server'.

### EXAMPLE 2

```powershell
Get-VideoDeviceStatistics -AsHashTable
```

Gets the video statistics of all cameras and returns the result as a hashtable where the keys are the camera ID's.

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

### -RecordingServerId

Specifies one or more Recording Server ID's to which the results will be limited.
Omit this parameter if you want device status from all Recording Servers

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases: Id

Required: False
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
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
