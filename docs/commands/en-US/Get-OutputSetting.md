---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-OutputSetting/
schema: 2.0.0
---

# Get-OutputSetting

## SYNOPSIS

Gets the settings for specified output.

## SYNTAX

### GeneralSettings
```
Get-OutputSetting -Output <Output> [-General] [-Name <String>] [-ValueInfo] [<CommonParameters>]
```

### StreamSettings
```
Get-OutputSetting -Output <Output> [-Stream] [-StreamNumber <Int32>] [-Name <String>] [-ValueInfo]
 [<CommonParameters>]
```

## DESCRIPTION

The `Get-OutputSetting` cmdlet returns a PSCustomObject with all the settings available for the specified output.

The values returned by this cmdlet are the "display values" that would be seen in the Management Client. To see a mapping 
of the "display values" to the raw values used by the MIP SDK, the "-ValueInfo" switch may be used.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-VmsOutput -Name 'Axis P3265-LVE (10.1.1.133) - Output 1' | Get-OutputSetting -General

<# OUTPUT (all values)
OutputModeType    : Real (1)
OutputTriggerTime : 500
#>
```

Gets all the output settings for the output named 'Axis P3265-LVE (10.1.1.133) - Output 1'. The "-General" switch is required.

### Example 2

```powershell
$o = Get-VmsOutput -Name 'Axis P3265-LVE (10.1.1.133) - Output 1'
Get-OutputSetting -Output $o -Name 'OutputTriggerTime' -General

<# OUTPUT (all values)
OutputTriggerTime
-----------------
500
#>
```

Another way of doing Example 1. Also, using the "-Name" parameter to specify the name of the setting.

### Example 3

```powershell
Get-VmsOutput -Name 'Axis P3265-LVE (10.1.1.133) - Output 1' | Get-OutputSetting -General -ValueInfo

<# OUTPUT (ValueInfo)
Setting           Property  Value
-------           --------  -----
OutputTriggerTime MinValue  100
OutputTriggerTime MaxValue  10000
OutputTriggerTime StepValue 1
#>
```

Gets the mapping of display values to the raw values. Sometimes the raw value is different from the
value that is displayed in the Management Client. When setting a value, the raw value has to be used.

## PARAMETERS

### -General

Specifies that the General settings should be returned. Outputs only have General settings so this switch
is required.

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

### -Output

Specifies the Output to retrieve the settings of, as returned by `Get-VmsOutput`.

```yaml
Type: Output
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Stream

** Not Used **

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

### VideoOS.Platform.ConfigurationItems.Output

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

## RELATED LINKS
