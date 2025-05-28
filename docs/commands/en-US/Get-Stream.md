---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-Stream/
schema: 2.0.0
---

# Get-Stream

## SYNOPSIS

Deprecated. Use `Get-VmsCameraStream` and `Set-VmsCameraStream` instead.

## SYNTAX

### LiveDefault (Default)
```
Get-Stream -Camera <Camera> [-LiveDefault] [-StreamIds] [<CommonParameters>]
```

### Recorded
```
Get-Stream -Camera <Camera> [-Recorded] [-StreamIds] [<CommonParameters>]
```

### All
```
Get-Stream -Camera <Camera> [-All] [-StreamIds] [<CommonParameters>]
```

## DESCRIPTION

Deprecated. Use `Get-VmsCameraStream` and `Set-VmsCameraStream` instead.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
# Deprecated
```

Deprecated. Use `Get-VmsCameraStream` and `Set-VmsCameraStream` instead.

## PARAMETERS

### -All

Deprecated. Use `Get-VmsCameraStream` and `Set-VmsCameraStream` instead.

```yaml
Type: SwitchParameter
Parameter Sets: All
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Camera

Deprecated. Use `Get-VmsCameraStream` and `Set-VmsCameraStream` instead.

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

### -LiveDefault

Deprecated. Use `Get-VmsCameraStream` and `Set-VmsCameraStream` instead.

```yaml
Type: SwitchParameter
Parameter Sets: LiveDefault
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recorded

Deprecated. Use `Get-VmsCameraStream` and `Set-VmsCameraStream` instead.

```yaml
Type: SwitchParameter
Parameter Sets: Recorded
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StreamIds

Deprecated. Use `Get-VmsCameraStream` and `Set-VmsCameraStream` instead.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Camera

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.StreamUsageChildItem

## NOTES

## RELATED LINKS
