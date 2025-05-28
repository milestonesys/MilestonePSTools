---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-ConfigurationItem/
schema: 2.0.0
---

# Set-ConfigurationItem

## SYNOPSIS

Store the updated ConfigurationItem including all properties and any filled childItems with Category=ChildItem

## SYNTAX

```
Set-ConfigurationItem -ConfigurationItem <ConfigurationItem> [<CommonParameters>]
```

## DESCRIPTION

Store the updated ConfigurationItem including all properties and any filled childItems with Category=ChildItem

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
$ms = Get-ConfigurationItem -Path "/"
$name = $ms.Properties | Where-Object Key -eq "Name"
$name.Value = "New Name"
$ms | Set-ConfigurationItem
```

Changes the Name property of the Management Server

## PARAMETERS

### -ConfigurationItem

Specifies the ConfigurationItem object to be updated.

Usually you will get the ConfigurationItem object using Get-ConfigurationItem.

```yaml
Type: ConfigurationItem
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.ConfigurationApi.ClientService.ConfigurationItem

Specifies the ConfigurationItem object to be updated.

Usually you will get the ConfigurationItem object using Get-ConfigurationItem.

## OUTPUTS

### VideoOS.ConfigurationApi.ClientService.ValidateResult

## NOTES

## RELATED LINKS

[MIP SDK Configuration API docs](https://doc.developer.milestonesys.com/html/index.html?base=gettingstarted/intro_configurationapi.html&tree=tree_4.html)

