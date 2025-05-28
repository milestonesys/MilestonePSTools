---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsLog/
schema: 2.0.0
---

# Get-VmsLog

## SYNOPSIS
Gets log records from the Milestone XProtect Log Server.

## SYNTAX

### TimestampFilter (Default)
```
Get-VmsLog [[-LogType] <String>] [[-StartTime] <DateTime>] [[-EndTime] <DateTime>] [[-Culture] <String>]
 [<CommonParameters>]
```

### Tail
```
Get-VmsLog [[-LogType] <String>] [-Tail] [[-Minutes] <Int64>] [[-Culture] <String>] [<CommonParameters>]
```

## DESCRIPTION
This cmdlet uses `[VideoOS.Platform.Log.LogClient]::Instance` to read logs of
the specified LogType. The log entries available are the same as the logs
available in Management Client, and do not include individual component logs
such as you will find in C:\ProgramData\Milestone\*.

The LogClient implementation in MIP SDK can result in exponentially slower read
performance when requesting logs over a long time span, so this cmdlet uses a
"windowing" strategy to break up the given range of time between StartTime and
EndTime. Initially, each request for logs uses a 10-minute range. If the number
of log entries in that 10-minute span of time is less than 500, the size of the
window will be increased in 5-minute increments.

If the number of log entries in a given period exceed 2000, then the window will
be adjusted down so that the next request contains closer to 1000 entries. The
minimum window size is 1 minute, and the maximum is 60 minutes.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
Get-VmsLog -LogType Audit -StartTime (Get-Date).Date.AddDays(-1) -EndTime (Get-Date).Date

<# OUTPUT
  Local time    : 1/31/2022 11:40:26 AM
  Message text  : User has accessed logs.
                  Log type: Audit
                  Time: 2022-01-28 21:00:41 to 2022-01-28 21:01:41 (UTC time)
  Permission    : Granted
  Category      : Log read
  Source type   : Audit
  Source name   :
  User          : [BASIC]\DEMO
  User location : 55.55.55.55
#>
```

Login to a Management Server using the login dialog, and then retrieve all
audit logs from the previous day, from midnight of the previous day to midnight
of today.

### Example 1
```powershell
Get-VmsLog

<# OUTPUT
  Log level    : Error
  Local time   : 1/31/2022 3:56:20 AM
  Message text : Communication error (hardware)
  Category     : Hardware and devices
  Source type  : Hardware
  Source name  : Mobotix M16 series (192.168.32.25)
  Event type   : Communication Error (Hardware)
#>
```

Without any parameters, the default behavior is to return the last 24 hours of
log entries from the System log.

### Example 1
```powershell
Get-VmsLog -LogType Audit -Tail -Minutes 90
```

Returns the last 90 minutes of audit logs.

## PARAMETERS

### -Culture
The culture value determines the language of logs returned by the MIP SDK
LogClient. The default value should be "System.Globalization.CultureInfo.CurrentCulture.Name"
and any alternative can be provided. If translations are not available for the
language associated with the provided culture, then the logs will be returned in
english.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndTime
Specifies the end of the time range from which logs should be returned.

```yaml
Type: DateTime
Parameter Sets: TimestampFilter
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogType
Specifies the type of log entry requested.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: System, Audit, Rules

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Minutes
Specifies the number of minutes to go back for the most recent logs. The logs
returned will reflect all log entries between "Minutes" ago, and "now".

```yaml
Type: Int64
Parameter Sets: Tail
Aliases:

Required: False
Position: 6
Default value: 60
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTime
Specifies the start of the time range from which logs should be returned.
Default value is [DateTime]::Now.AddHours(-24).

```yaml
Type: DateTime
Parameter Sets: TimestampFilter
Aliases: BeginTime

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tail
Specifies that the "tail", or the most recent entries from the specified log
should be returned. The StartTime for the request is determined by subtracting
the value specified by "Minutes" from [DateTime]::Now.

```yaml
Type: SwitchParameter
Parameter Sets: Tail
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
