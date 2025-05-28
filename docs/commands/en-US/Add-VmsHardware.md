---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-VmsHardware/
schema: 2.0.0
---

# Add-VmsHardware

## SYNOPSIS

Adds a new hardware device, typically a camera, to a Milestone XProtect Recording Server.

## SYNTAX

### FromHardwareScan
```
Add-VmsHardware -HardwareScan <VmsHardwareScanResult[]> [-Name <String>] [-SkipConfig] [-Force]
 [<CommonParameters>]
```

### Manual
```
Add-VmsHardware -RecordingServer <RecordingServer> -HardwareAddress <Uri> [-Name <String>]
 [-DriverNumber <Int32>] [-HardwareDriverPath <String>] -Credential <PSCredential> [-SkipConfig] [-Force]
 [<CommonParameters>]
```

## DESCRIPTION

Adds a new hardware device, typically a camera, to a Milestone XProtect Recording Server.
Capable of adding multiple cameras in a group if a collection of hardware scan results from the
Start-VmsHardwareScan command are provided in the HardwareScan parameter.
Otherwise one camera
will be added at a time.

Each successfully added hardware device will be returned to the pipeline in a fully resolved
Hardware object.
With that object you can continue to set properties on the hardware or child
camera, microphone, speaker and other child device types that are present.

IMPORTANT: This command does not add any devices to a device group like the Management Client
does.
You must put devices into device groups yourself.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
$recorder = Get-VmsRecordingServer | Out-GridView -OutputMode Single
$recorder | Add-VmsHardware -HardwareAddress 10.1.1.100 -Name 'Parking' -DriverNumber 806 -Credential (Get-Credential)
```

Prompts to enter a username and password (thanks to Get-Credential) and then adds the Axis camera at 10.1.1.100 to the
Recording Server in $recorder.
Once added, the new hardware will be returned to the pipeline and in this case shown in the
terminal like you see below.

Name    Address             Model                       Enabled LastModified         Id
----    -------             -----                       ------- ------------         --
Parking http://10.1.1.100/  AXIS M1065-L Network Camera True    10/5/2021 9:50:21 PM A833F561-7830-41B4-BEEF-C1F868939D17

### EXAMPLE 2

```powershell
$recorder = Get-VmsRecordingServer | Out-GridView -OutputMode Single
$credential = [pscredential]::new('root', ('pass' | ConvertTo-SecureString -AsPlainText -Force))
$recorder | Add-VmsHardware -HardwareAddress 10.1.1.100 -Name 'Parking' -DriverNumber 806 -Credential $credential
```

Exactly the same as Example #1 however in this example we create the credential from code.
This uses plain text and is
generally frowned upon for security reasons.
Ideally you can prompt the user to enter credentials, or you store credentials
in a safe place such as a secret store of some kind.
Microsoft have provided a handy secret management framework with plugin
support called "Microsoft.PowerShell.SecretManagement" enabling you to easily access secret management tools like KeePass and
others.

### EXAMPLE 3

```powershell
$newHardware = Add-VmsHardware -HardwareScan (Start-VmsHardwareScan -RecordingServer (Get-VmsRecordingServer) -Express)
$newHardware
```

This one-liner will get all recording servers in the site, and start an express hardware scan on them all.
The completed hardware
scans will be passed into Add-VmsHardware, and all the newly added hardware from all recording servers will be saved in the $newHardware
variable.

## PARAMETERS

### -Credential

Specifies an admin username and password to use with the camera at the given address.

```yaml
Type: PSCredential
Parameter Sets: Manual
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriverNumber

Specifies the driver number for the Milestone device pack driver to use with
the camera. One of either HardwareDriverPath or DriverNumber are required.

```yaml
Type: Int32
Parameter Sets: Manual
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Specifies that the camera(s) should be added even if they already exist on another Recording
Server on the site.

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

### -HardwareAddress

Specifies the IP or hostname of the hardware to be added.
This should be in URI format.
Example: http://192.168.1.100

```yaml
Type: Uri
Parameter Sets: Manual
Aliases: Address

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -HardwareDriverPath

Specifies the Milestone Configuration API path value for the driver to use.
DriverNumber is more user-friendly but if you have the path, you can use that
instead. One of either HardwareDriverPath or DriverNumber are required.
Example: HardwareDriver\[ada01bd5-fc87-4bcb-8e7e-145cc755f502\]

```yaml
Type: String
Parameter Sets: Manual
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -HardwareScan

The results of Start-VmsHardwareScan which contain all the required information to add hardware
including the address, username, password, and driver.

```yaml
Type: VmsHardwareScanResult[]
Parameter Sets: FromHardwareScan
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name

Specifies the name to be assigned to the hardware after it has been added.
The default behavior is to use the
camera make, model and IP.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecordingServer

Specifies the RecordingServer object (from Get-VmsRecordingServer for example) to which the camera
should be added.
This is only relevant for the manual parameter set.
If using hardware scan
results as input to Add-VmsHardware, the Recording Server is retrieved from the scan result object.

```yaml
Type: RecordingServer
Parameter Sets: Manual
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -SkipConfig

Specifies that no additional configuration should be performed once the hardware has been
added.
This means the hardware and devices will keep their default names, and will be disabled
until you enable them yourself.
You might do this if you plan to make several of your own
configuration changes once the device is added and that might save some time especially when
working with a large number of devices.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Hardware

### VideoOS.Platform.ConfigurationItems.Hardware

This command does not add any cameras or other devices to a camera group.
It is expected that you will do this yourself if you
wish.

## NOTES

## RELATED LINKS
