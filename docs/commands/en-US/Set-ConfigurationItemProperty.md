---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-ConfigurationItemProperty/
schema: 2.0.0
---

# Set-ConfigurationItemProperty

## SYNOPSIS

Sets the value of a given ConfigurationItem property by key

## SYNTAX

```
Set-ConfigurationItemProperty [-InputObject] <ConfigurationItem> [-Key] <String> [-Value] <String> [-PassThru]
 [<CommonParameters>]
```

## DESCRIPTION

A ConfigurationItem may have zero or more Property objects in the Properties array.
Each property has a key name
and a value.
Since the Properties property on a ConfigurationItem has no string-based indexer, you are required
to search the array of properties for the one with the Key you're interested in, and then set the Value property
on it.

This cmdlet is a simple wrapper which does the Where-Object for you, throws an error if the Key does not exist,
and optionally passes the modified ConfigurationItem back into the pipeline.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ConfigurationItem -Path / | Set-ConfigurationItemProperty -Key Description -Value 'A new description' -PassThru | Set-ConfigurationItem
```

Gets a ConfigurationItem representing the Management Server, changes the Description property, and pushes the
change to the Management Server using Set-ConfigurationItem.

## PARAMETERS

### -InputObject

A \[VideoOS.ConfigurationApi.ClientService.ConfigurationItem\] with a property to be modified.

```yaml
Type: ConfigurationItem
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Key

A string representing the key of the property to be modified.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru

Pass the modified ConfigurationItem from $InputObject back into the pipeline.

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

### -Value

A string value to be used as the new value for the property named by the given key.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
