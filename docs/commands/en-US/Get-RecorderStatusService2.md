---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-RecorderStatusService2/
schema: 2.0.0
---

# Get-RecorderStatusService2

## SYNOPSIS

Gets a RecorderStatusService2 class for directly interacting with the RecorderStatusService2 api.

## SYNTAX

### FromRecordingServer (Default)
```
Get-RecorderStatusService2 -RecordingServer <RecordingServer> [<CommonParameters>]
```

### FromUri
```
Get-RecorderStatusService2 -Uri <Uri> [<CommonParameters>]
```

## DESCRIPTION

See the MIP SDK documentation for detailed information about the RecorderStatusService2 api.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
Connect-Vms -ShowDialog -AcceptEula
$recorder = Get-VmsRecordingServer | Out-GridView -OutputMode Single
$service = $recorder | Get-RecorderStatusService2
$cameraIds = ($recorder | Get-VmsHardware | Get-VmsCamera).Id
$service.GetVideoDeviceStatistics((Get-VmsToken), $cameraIds)
```

After ensuring there is an open connection to the Management Server, a grid view
is displayed with a list of Recording Servers. Once a Recording Server is selected,
a RecorderStatusService2 instance is created, and that service is used to retrieve
raw VideoDeviceStatistics from the Recording Server.

## PARAMETERS

### -RecordingServer

Specifies the RecordingServer for which a RecorderStatusService2 client should be instantiated.

```yaml
Type: RecordingServer
Parameter Sets: FromRecordingServer
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Uri
Specifies the URI of the Recording Server for which the RecorderStatusService2
should be instantiated. For example: http://localhost:7563

```yaml
Type: Uri
Parameter Sets: FromUri
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.RecordingServer

Specifies the RecordingServer for which a RecorderStatusService2 client should be instantiated.

## OUTPUTS

### VideoOS.Platform.SDK.Proxy.Status2.RecorderStatusService2

## NOTES

## RELATED LINKS
