---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-HardwareSetting/
schema: 2.0.0
---

# Get-HardwareSetting

## SYNOPSIS

Gets the settings for specified IP hardware.

## SYNTAX

```
Get-HardwareSetting -Hardware <Hardware> [-Name <String>] [-ValueTypeInfo] [-IncludeReadWriteOnly]
 [<CommonParameters>]
```

## DESCRIPTION

The `Get-HardwareSetting` cmdlet returns a PSCustomObject with all the settings available for the specified hardware, 
including read-only settings and settings usually hidden from the Management Client user interface.

Settings often include properties like "HTTPS Enabled" and "HTTPS Port", which apply to the hardware as a whole.

Each hardware model may have a different set of settings (especially across manufacturers) and some may not have 
any settings.

The values returned by this cmdlet are the "display values" that would be seen in the Management Client. To see a mapping 
of the "display values" to the raw values used by the MIP SDK, the "-ValueTypeInfo" switch may be used.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-VmsHardware -Name 'Axis P3265-LVE (10.1.1.133)' | Get-HardwareSetting

<# OUTPUT (all values)
DetectedModelName        : AXIS P3265-LVE Dome Camera
ProductID                : Axis
MacAddress               : B8A44F64CC37
FirmwareVersion          : 11.11.73
SerialNumber             : B8A44F64CC37
AbsoluteTime             : no
Bandwidth                : Unlimited
HTTPSEnabled             : no
HTTPSPort                : 443
HTTPSValidateCertificate : No
HTTPSValidateHostname    : No
MulticastStartPort       : 50000
MulticastEndPort         : 50999
AuthenticationType       : Automatic
ZipstreamSupportedType   : yes
OSDMetadataType          : off
AuxUse                   : PTZ
Rotation                 : 180
PasswordChangeSupported  : Yes
PasswordChangeMinLength  : 1
PasswordChangeMaxLength  : 64
FirmwareUpgradeSupported : Yes
RecorderAddress          :
RecorderCredentials      :
#>
```

Gets all the hardware settings for the hardware named 'Axis P3265-LVE (10.1.1.133)'.

### Example 2

```powershell
$hw = Get-VmsHardware -Name 'Axis P3265-LVE (10.1.1.133)'
Get-HardwareSetting -Hardware $hw -IncludeReadWriteOnly

<# (only read/write values)
AbsoluteTime             : no
Bandwidth                : Unlimited
HTTPSEnabled             : no
HTTPSPort                : 443
HTTPSValidateCertificate : No
HTTPSValidateHostname    : No
MulticastStartPort       : 50000
MulticastEndPort         : 50999
AuthenticationType       : Automatic
OSDMetadataType          : off
AuxUse                   : PTZ
Rotation                 : 180
#>
```

Another way of doing Example 1. Also added the "IncludeReadWriteOnly" parameter so it only returns
results that are read/write.

### Example 3

```powershell
Get-VmsHardware -Name 'Axis P3265-LVE (10.1.1.133)' | Get-HardwareSetting -Name HTTPSPort
```

Gets the value of the HTTPSPort for the hardware named 'Axis P3265-LVE (10.1.1.133)'.

### Example 4

```powershell
Get-VmsHardware -Name 'Axis P3265-LVE (10.1.1.133)' | Get-HardwareSetting -ValueTypeInfo

<# OUTPUT (Value Type Info)
Axis                 : Axis
No                   : No
Yes                  : Yes
Unlimited            : Unlimited
4 Mbit               : 4 Mbit
3 Mbit               : 3 Mbit
2 Mbit               : 2 Mbit
1 Mbit               : 1 Mbit
768 Kbit             : 768 Kbit
512 Kbit             : 512 Kbit
256 Kbit             : 256 Kbit
128 Kbit             : 128 Kbit
64 Kbit              : 64 Kbit
MinValue             : 0
MaxValue             : 65535
StepValue            : 1
None                 : None
Basic                : Basic
Digest               : Digest
Automatic            : Automatic
On                   : on
Off                  : off
PTZ Movement         : PTZ
Wiper/Washer Control : Wiper
0                    : 0
90                   : 90
180                  : 180
270                  : 270
#>
```

Gets the mapping of display values to the raw values. Sometimes the raw value is different from the
value that is displayed in the Management Client. When setting a value, the raw value has to be used.

## PARAMETERS

### -Hardware

Specifies hardware object such as are returned by `Get-VmsHardware`.

```yaml
Type: Hardware
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -IncludeReadWriteOnly

Specifies that only read/write values of settings should be returned instead of also returning values that are read only.

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

### -Name

Specifies the name of a specific setting to be returned.

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

### -ValueTypeInfo

Specifies that the PSCustomObject should contain a "ValueTypeInfo" collection for each setting, 
instead of the value of the setting. The "ValueTypeInfo" collections can be used to discover 
the valid ranges or values for each setting.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Hardware

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
