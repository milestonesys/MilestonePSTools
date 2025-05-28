---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsDeviceStatus/
schema: 2.0.0
---

# Get-VmsDeviceStatus

## SYNOPSIS
Gets the current device status for any streaming device directly from the recording server.

## SYNTAX

```
Get-VmsDeviceStatus [[-RecordingServerId] <Guid[]>] [[-DeviceType] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Recording Servers offer a status interface called RecorderStatusService2. This
service has a method called GetCurrentDeviceStatus which can return the current
state of any streaming device type including cameras, microphones, speakers,
and metadata, as well as IO device types including inputs and outputs.

This cmdlet will return status for one or more of the streaming device
types, and the results will include all devices of the specified
type(s) that are active on the recording server.

Note that the Motion property will always be false for anything but the Camera
device type.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
Get-VmsDeviceStatus -DeviceType Camera, Microphone

<# OUTPUT
  DeviceName         : Learning & Performance (Bosch 7000VR)
  DeviceType         : Camera
  RecorderName       : Milestone Demo
  RecorderId         : 72080191-d39d-4229-b151-65bcd740c393
  Motion             : False
  Recording          : False
  DbMoveInProgress   : False
  ErrorOverflow      : False
  ErrorWritingGop    : False
  DbRepairInProgress : False
  DeviceId           : 004962d3-b129-4099-8c6e-0f8bff8385b0
  IsChange           : False
  Enabled            : True
  Started            : True
  Error              : False
  ErrorNotLicensed   : False
  ErrorNoConnection  : False
  Time               : 1/27/2022 11:33:32 PM
#>
```

After logging in to the Management Server, the status of all enabled cameras
and microphones is returned. The example shows all properties available on the
resulting VmsStreamDeviceStatus object.

### EXAMPLE 2
```powershell
Get-VmsDeviceStatus
```

Returns the status of all cameras on all recording servers. The default
DeviceType value is 'Cameras', so if that is all you need, you may omit the
DeviceType parameter like this. And when no recording server ID's are provided,
status requests are sent to all recording servers.

### EXAMPLE 3
```powershell
Get-VmsRecordingServer -Name 'Recorder1' | Get-VmsDeviceStatus
```

Returns the status of all cameras on recording server named "Recorder1". The
RecordingServerId property has an alias of "Id" and accepts values from the
pipeline by property name, so you can pipe a Recording Server object to this
cmdlet.

## PARAMETERS

### -DeviceType
Specifies one or more streaming device types to retrieve status for.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Camera, Microphone, Speaker, Metadata

Required: False
Position: 1
Default value: Camera
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecordingServerId
Specifies one or more Recording Server ID's. Omit this parameter and all
recording servers will be queried for status.

```yaml
Type: Guid[]
Parameter Sets: (All)
Aliases: Id

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### [VmsStreamDeviceStatus]

## NOTES

If one or more status entries have a DeviceId value of
"00000000-0000-0000-0000-000000000000", this means the recording server has not
been able to load the device configuration yet. This should normally not happen
except perhaps for a short period after the recording server is started. If the
issue does not resolve on it's own, it's possible you are impacted by an issue
solved by a cumulative patch available for your product version. If you're
unable to resolve the issue and the camera is unavailable in XProtect Smart Client, you
should open a support case with Milestone technical support.

The following log message from the recording server's RecorderEngine.log file
at C:\ProgramData\Milestone\XProtect Recording Server\Logs is one error that is
known to result in device status messages like this.

2022-01-27 16:33:48.620-08:00 [     7] ERROR      - Unable to get driver update changes (Retries: 323). Hardware Id: fbcf40ba-e807-419a-8e11-e782551190a5; Hardware model: Bosch1ch;

## RELATED LINKS
