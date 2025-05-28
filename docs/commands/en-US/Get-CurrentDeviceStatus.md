---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-CurrentDeviceStatus/
schema: 2.0.0
---

# Get-CurrentDeviceStatus

## SYNOPSIS

Gets the current device status of all devices of the desired type from one or more recording servers

## SYNTAX

```
Get-CurrentDeviceStatus [[-RecordingServerId] <Guid[]>] [[-DeviceType] <String[]>] [-AsHashTable]
 [[-RunspacePool] <RunspacePool>] [<CommonParameters>]
```

## DESCRIPTION

Uses the RecorderStatusService2 client to call GetCurrentDeviceStatus and receive the current status
of all devices of the desired type(s).
Specify one or more types in the DeviceType parameter to receive
status of more device types than cameras.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsRecordingServer -Name 'My Recording Server' | Get-CurrentDeviceStatus -DeviceType All
```

Gets the status of all devices of all device types from the Recording Server named 'My Recording Server'.

### EXAMPLE 2

```powershell
Get-CurrentDeviceStatus -DeviceType Camera, Microphone
```

Gets the status of all cameras and microphones from all recording servers.

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

### -DeviceType

Specifies the type of devices to include in the results.
By default only cameras will be included and you can expand this to include all device types

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Camera, Microphone, Speaker, Metadata, Input event, Output, Event, Hardware, All

Required: False
Position: 1
Default value: Camera
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
