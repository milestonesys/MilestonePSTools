---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-MetadataSetting/
schema: 2.0.0
---

# Get-MetadataSetting

## SYNOPSIS

Gets the general or stream settings for specified metadata.

## SYNTAX

### GeneralSettings
```
Get-MetadataSetting -Metadata <Metadata> [-General] [-Name <String>] [-ValueInfo] [<CommonParameters>]
```

### StreamSettings
```
Get-MetadataSetting -Metadata <Metadata> [-Stream] [-StreamNumber <Int32>] [-Name <String>] [-ValueInfo]
 [<CommonParameters>]
```

## DESCRIPTION

The `Get-MetadataSetting` cmdlet returns a PSCustomObject with the general or stream settings available for the specified metadata.

The values returned by this cmdlet are the "display values" that would be seen in the Management Client. To see a mapping 
of the "display values" to the raw values used by the MIP SDK, the "-ValueInfo" switch may be used.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-VmsMetadata -Name 'Axis P3265-LVE (10.1.1.133) - Metadata 1' | Get-MetadataSetting -General

<# OUTPUT (general values)
ValidTime
---------
3
#>
```

Gets the general settings for the metadata named 'Axis P3265-LVE (10.1.1.133) - Metadata 1'.

### Example 2

```powershell
$metadata = Get-VmsMetadata -Name 'Axis P3265-LVE (10.1.1.133) - Metadata 1'
Get-MetadataSetting -Metadata $metadata -Stream -Name MetadataStreamingMode

<# OUTPUT (stream value)
MetadataStreamingMode
---------------------
HTTP
#>
```

Gets the stream setting value for MetadataStreamingMode for the metadata named 'Axis P3265-LVE (10.1.1.133) - Metadata 1'.

### Example 3

```powershell
Get-VmsMetadata -Name 'Axis P3265-LVE (10.1.1.133) - Metadata 1' | Get-MetadataSetting -Stream -ValueInfo

<# OUTPUT (ValueInfo)
Setting               Property          Value
-------               --------          -----
MetadataEvents        No                no
MetadataEvents        Yes               yes
MetadataPtz           No                no
MetadataPtz           Yes               yes
MetadataStreamingMode RTP/UDP           UDP
MetadataStreamingMode RTP/RTSP/TCP      TCP
MetadataStreamingMode RTP/RTSP/HTTP/TCP HTTP
MetadataStreamingMode SRTP/RTSPS/UDP    SRTP
MetadataStreamingMode SRTP/RTSPS/TCP    SRTP_TCP
MetadataAnalytics     No                no
MetadataAnalytics     Yes               yes
#>
```

Gets the mapping of display values to the raw values. Sometimes the raw value is different from the
value that is displayed in the Management Client. When setting a value, the raw value has to be used.

## PARAMETERS

### -General

Specifies that the General settings should be returned.

```yaml
Type: SwitchParameter
Parameter Sets: GeneralSettings
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Metadata

Specifies the Metadata to retrieve the settings of, as returned by `Get-VmsMetadata`.

```yaml
Type: Metadata
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name

Specifies the name of the property to be returned.

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

### -Stream

Specifies that the Stream settings should be returned.

```yaml
Type: SwitchParameter
Parameter Sets: StreamSettings
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StreamNumber

** Not Used **

```yaml
Type: Int32
Parameter Sets: StreamSettings
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ValueInfo

Specifies that the PSCustomObject should contain a "ValueInfo" collection for each setting, 
instead of the value of the setting. The "ValueInfo" collections can be used to discover 
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

### VideoOS.Platform.ConfigurationItems.Metadata

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
