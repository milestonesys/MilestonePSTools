---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-ConfigurationItemProperty/
schema: 2.0.0
---

# Get-ConfigurationItemProperty

## SYNOPSIS

Gets the value of a given ConfigurationItem property by key

## SYNTAX

```
Get-ConfigurationItemProperty [-InputObject] <ConfigurationItem> [-Key] <String> [<CommonParameters>]
```

## DESCRIPTION

A ConfigurationItem may have zero or more Property objects in the Properties array.
Each property has a key name
and a value.
Since the Properties property on a ConfigurationItem has no string-based indexer, you are required
to search the array of properties for the one with the Key you're interested in, and then get the Value property
of it.

This cmdlet is a simple wrapper which does the Where-Object for you, and throws an error if the Key does not exist.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
$description = Get-ConfigurationItem -Path / | Get-ConfigurationItemProperty -Key Description
$description
```

Gets a ConfigurationItem representing the Management Server, and returns the Description value.
The alternative
is to do ((Get-ConfigurationItem -Path /).Properties | Where-Object Key -eq Description).Value.

## PARAMETERS

### -InputObject

A \[VideoOS.ConfigurationApi.ClientService.ConfigurationItem\] with a property to be retrieved.

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

A string representing the key of the property from which the value should be retrieved.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
