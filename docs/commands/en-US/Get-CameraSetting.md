---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-CameraSetting/
schema: 2.0.0
---

# Get-CameraSetting

## SYNOPSIS

Deprecated. Use `Get-VmsCameraGeneralSetting` and `Get-VmsCameraStream` instead.

## SYNTAX

### GeneralSettings
```
Get-CameraSetting -Camera <Camera> [-General] [-Name <String>] [-ValueTypeInfo] [<CommonParameters>]
```

### StreamSettings
```
Get-CameraSetting -Camera <Camera> [-Stream] [-StreamNumber <Int32>] [-Name <String>] [-ValueTypeInfo]
 [<CommonParameters>]
```

## DESCRIPTION

Deprecated. Use `Get-VmsCameraGeneralSetting` and `Get-VmsCameraStream` instead.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
# Deprecated
```

Deprecated. Use `Get-VmsCameraGeneralSetting` and `Get-VmsCameraStream` instead.

## PARAMETERS

### -Camera

Deprecated. Use `Get-VmsCameraGeneralSetting` and `Get-VmsCameraStream` instead.

```yaml
Type: Camera
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -General

Deprecated. Use `Get-VmsCameraGeneralSetting` and `Get-VmsCameraStream` instead.

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

### -Name

Deprecated. Use `Get-VmsCameraGeneralSetting` and `Get-VmsCameraStream` instead.

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

Deprecated. Use `Get-VmsCameraGeneralSetting` and `Get-VmsCameraStream` instead.

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

Deprecated. Use `Get-VmsCameraGeneralSetting` and `Get-VmsCameraStream` instead.

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

### -ValueTypeInfo

Deprecated. Use `Get-VmsCameraGeneralSetting` and `Get-VmsCameraStream` instead.

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

### VideoOS.Platform.ConfigurationItems.Camera

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
