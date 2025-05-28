---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-MetadataSetting/
schema: 2.0.0
---

# Set-MetadataSetting

## SYNOPSIS

Sets a general or stream setting for a metadata based on the setting name/key.

## SYNTAX

### GeneralSettings
```
Set-MetadataSetting -Metadata <Metadata> [-General] -Name <String> -Value <String> [<CommonParameters>]
```

### StreamSettings
```
Set-MetadataSetting -Metadata <Metadata> [-Stream] [-StreamNumber <Int32>] -Name <String> -Value <String>
 [<CommonParameters>]
```

## DESCRIPTION

The `Set-MetadataSetting` cmdlet enables settings to be updated on metadatas with minimal effort.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-VmsMetadata -Name 'Axis P3265-LVE (10.1.1.133) - Metadata 1' | Set-MetadataSetting -General -Name ValidTime -Value 5
```

Sets the "ValidTime" (Valid time (seconds)) value in General settings to 5 for the metadata named 'Axis P3265-LVE (10.1.1.133) - Metadata 1'

### Example 2

```powershell
Get-VmsMetadata -Name 'Axis P3265-LVE (10.1.1.133) - Metadata 1' | Set-MetadataSetting -Stream -Name MetadataEvents -Value no
```

Sets the "MetadataEvents" (Analytics data) value in Stream settings to "no" for the metadata named 'Axis P3265-LVE (10.1.1.133) - Metadata 1'

## PARAMETERS

### -General

Specifies that the setting applies to the General settings, as opposed to the Stream settings.

```yaml
Type: SwitchParameter
Parameter Sets: GeneralSettings
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Metadata

Specifies the Metadata to be updated as returned by `Get-VmsMetadata`.

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

Specifies the name of the property to be updated.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Stream

Specifies that the setting applies to the Stream settings, as opposed to the General settings.

```yaml
Type: SwitchParameter
Parameter Sets: StreamSettings
Aliases:

Required: True
Position: Named
Default value: False
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

### -Value

Specifies the value for updating the specified property.

```yaml
Type: String
Parameter Sets: (All)
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

### VideoOS.Platform.ConfigurationItems.Metadata

## OUTPUTS

## NOTES

## RELATED LINKS
