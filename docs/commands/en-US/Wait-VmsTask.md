---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Wait-VmsTask/
schema: 2.0.0
---

# Wait-VmsTask

## SYNOPSIS

Polls a Milestone XProtect Task item until the task completes.

## SYNTAX

```
Wait-VmsTask [-Path] <String[]> [[-Title] <String>] [-Cleanup] [<CommonParameters>]
```

## DESCRIPTION

Some long running operations like hardware scans and adding hardware return a "Task" item
which provides status and progress information, and when the status of the task reaches either
Error or Success, the properties of the task will contain useful information about a new item
or other data depending on the operation.
Or if there was an error, the ErrorCode and ErrorText
properties will be filled in.

Wait-VmsTask provides you with a way to monitor one or more tasks simultaneously, and block
until all tasks have completed.
If $ProgressPreference is set to Continue (default) then you
will also get a progress bar showing a rough % complete and estimated remaining time value.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Wait-VmsTask -Path ($recorder | Start-VmsHardwareScan -Express -PassThru).Path -Cleanup
```

Starts an "express" hardware scan on the Recording Server specified in the $recorder variable.
The Start-VmsHardwareScan
normally calls Wait-VmsTask for you, but with the PassThru parameter the scan will be started and the task returned to you.
We then pass all the paths into the Path parameter on Wait-VmsTask and when the tasks complete, they will be cleaned up and
returned to the pipeline for the next step.

## PARAMETERS

### -Cleanup

Specifies whether the "TaskCleanup" method should be called on each task as it completes.

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

Specifies the Task path in Milestone's Configuration API format.
Example: `Task[100]`.

REQUIREMENTS  

- Allowed item types: Task

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Title

Specifies the activity name to display in the progress bar.
The default is "Waiting for VMS Task(s) to complete".

```yaml
Type: String
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
