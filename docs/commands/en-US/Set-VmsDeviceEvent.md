---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsDeviceEvent/
schema: 2.0.0
---

# Set-VmsDeviceEvent

## SYNOPSIS
Used to enable, disable, or modify device events provided by hardware added to a recording server.

## SYNTAX

```
Set-VmsDeviceEvent [-DeviceEvent] <HardwareDeviceEventChildItem> [[-Used] <Boolean>] [[-Enabled] <Boolean>]
 [[-Index] <String>] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsDeviceEvent` cmdlet is used to "add" or "remove" an event on a Hardware, Camera, Microphone, Speaker, Input,
Output, or Metadata device, by setting the value of `Used` to `$true` or `$false` respectively. Events that are "used"
can then be enabled or disabled by setting the `Enabled` property accordingly.

Some events, such as some hardware-based motion detection events, have an `EventIndex` property which can provide additional
information like the ID of a motion detection window. This setting can be modified with the `Index` parameter when needed.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.1

## EXAMPLES

### Example 1
```powershell
Get-VmsCamera | Get-VmsDeviceEvent -Name 'Motion St*ed (HW)' | Set-VmsDeviceEvent -Used $true -Enabled $true -WhatIf
```

Add and enable the hardware-based motion started/stopped events on all enabled cameras on the Milestone server. Note
that the `-WhatIf` switch parameter should be removed from the `Set-VmsDeviceEvent` command if you want the changed to
be made on the server.

### Example 2
```powershell
Get-VmsCamera | Get-VmsDeviceEvent -Name '*tripwire*' | Set-VmsDeviceEvent -Used $false -WhatIf
```

Disable any "\*tripwire\*" events available on all enabled cameras.

### Example 3
```powershell
# On selected cameras, ensure recording is enabled, and disable the prebuffer as it isn't useful for cameras that only stream on motion.
# Then add/enable the "Motion Started (HW)" and "Motion Stopped (HW)" events on each of the selected cameras.
$selectedCameras = Select-Camera -AllowFolders -AllowServers -RemoveDuplicates -Title 'Select cameras to configure for edge-based motion detection'
$selectedCameras | Set-VmsCamera -RecordingEnabled $true -PrebufferEnabled $false -PassThru | Get-VmsDeviceEvent -Name 'Motion*(HW)' | Set-VmsDeviceEvent -Used $true -Enabled $true -Index 1 -PassThru

# Create a rule to start camera feeds on edge-based motion detection events, and to retrieve the previous 15 seconds of recordings from the camera's edge storage if available.
$ruleArgs = @{
    Name       = 'Start Feed and Record on Motion Started (HW)'
    Properties = @{
        'Description'                                     = 'Start live stream, start recording, and retrieve last 15 seconds from edge storage when camera detects motion.'
        'StartRuleType'                                   = 'Event'
        'StartEventGroup'                                 = 'DeviceConfigurable'
        'StartEventType'                                  = 'a7bd4b94-6eb0-4b5d-92d9-23f69bd23824'
        'StartEventSources'                               = 'CameraGroup[0e1b0ad3-f67c-4d5f-b792-4bd6c3cf52f8]'
        'StopRuleType'                                    = 'Event'
        'StopEventGroup'                                  = 'DeviceConfigurable'
        'StopEventType'                                   = 'e3dd8ed6-cf93-410d-818a-6c474414d885'
        'StopEventSources'                                = 'CameraGroup[0e1b0ad3-f67c-4d5f-b792-4bd6c3cf52f8]'
        'StartActions'                                    = 'StartRecording;StartFeed;RetrieveEdgeStorage'
        'Start.StartRecording.Delay'                      = 0
        'Start.StartRecording.DeviceIds'                  = 'Camera[00000000-0000-0000-0000-000000000000]'
        'Start.StartFeed.DeviceIds'                       = 'Camera[00000000-0000-0000-0000-000000000000]'
        'Start.RetrieveEdgeStorage.Delay'                 = 0
        'Start.RetrieveEdgeStorage.DeviceIds'             = 'Camera[00000000-0000-0000-0000-000000000000]'
        'Start.RetrieveEdgeStorage.RetrieveSecondsBefore' = '-15'
        'StopActions'                                     = 'StopRecording;StopFeed'
        'Stop.StopRecording.Delay'                        = '15'
        'Stop.StopFeed.Delay'                             = '15'
    }
}
New-VmsRule @ruleArgs -Verbose
```

This example demonstrates how you can enable the hardware-based or edge motion started/stopped events on many cameras at
once, combined with creating a rule to start camera feeds on the "Motion Started (HW)" events and retrieving the previous
15 seconds of recordings from edge storage if available.

Note that the "Default Start Feed Rule" should be disabled if you do not want the camera to stream to the recording
server all the time.

## PARAMETERS

### -DeviceEvent
Specifies the device event to modify use `Get-VmsDeviceEvent` to retrieve a list of available DeviceEvents.

```yaml
Type: HardwareDeviceEventChildItem
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Enabled
Specifies a new value for the Enabled property on the device event.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Index
Specifies a new value for the EventIndex property on the device event.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Returns each device event back to the pipeline whether it was modified or not.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Used
Specifies a new value for the EventUsed property on the device event. When the value is set to `$true` the event is "added"
on the device. If this value was previously `$false`, the Enabled property is automatically set to `$true` to match the
behavior of the management client.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
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

### VideoOS.Platform.ConfigurationItems.HardwareDeviceEventChildItem

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.HardwareDeviceEventChildItem

## NOTES

## RELATED LINKS
