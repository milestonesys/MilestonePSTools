---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Find-ConfigurationItem/
schema: 2.0.0
---

# Find-ConfigurationItem

## SYNOPSIS

Quickly finds configuration items matching a specified Name, ItemType and Properties filters

## SYNTAX

```
Find-ConfigurationItem [[-Name] <String>] [[-ItemType] <String[]>] [[-EnableFilter] <String>]
 [[-Properties] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION

Quickly finds configuration items matching a specified Name, ItemType and Properties filters
by using the QueryItems method available in the Configuration API.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Find-ConfigurationItem -ItemType Camera -Name Parking
```

Returns a generic Configuration API item for each camera containing the word "parking" anywhere in the display name.

### EXAMPLE 2

```powershell
Find-ConfigurationItem -ItemType Hardware -Properties @{ Address = '192.168.1.101' }
```

Returns a generic Configuration API item for each hardware with the IP address 192.168.1.101 present in the 'Address' property of the hardware device.
Hardware typically have an address in the format of 'http://192.168.1.101/'.

### EXAMPLE 3

```powershell
Find-ConfigurationItem -ItemType Camera -Name Parking | ConvertFrom-ConfigurationItem
```

Finds every camera containing the word "parking" anywhere in the display name and converts it from a generic Configuration API item to a strongly-typed Camera object such as what you will get when using Get-VmsCamera.

## PARAMETERS

### -EnableFilter

Specifies whether all matching items should be included, or whether only enabled, or disabled items should be included in the results.
The default is to include all items regardless of state.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: All, Disabled, Enabled

Required: False
Position: 2
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -ItemType

Specifies the type(s) of items to include in the results.
The default is to include only 'Camera' items.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Camera
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Specifies all, or part of the display name of the configuration item to search for.
For example, if you want to find a camera named "North West Parking" and you specify the value 'Parking', you will get results for any camera where 'Parking' appears in the name somewhere.
The search is not case sensitive.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Properties

An optional hashtable of additional property keys and values to filter results.
Properties must be string types, and the results will be included if the property key exists, and the value contains the provided string.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

The QueryItems method was added to Configuration API on the Milestone XProtect Management Server starting with version 2020 R2.
If your Milestone VMS version is 2020 R1 or earlier, you will receive an error when using this command.

## RELATED LINKS

[MIP SDK Docs - QueryItems](https://doc.developer.milestonesys.com/html/index.html?base=miphelp/class_video_o_s_1_1_configuration_api_1_1_client_service_1_1_query_items.html&tree=tree_search.html?search=queryitems)

