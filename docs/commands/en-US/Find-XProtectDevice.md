---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Find-XProtectDevice/
schema: 2.0.0
---

# Find-XProtectDevice

## SYNOPSIS

Finds devices and provides the names of the parent hardware and recording server to help quickly locate devices by name.

## SYNTAX

```
Find-XProtectDevice [-ItemType <String[]>] [-Name <String>] [-Address <String>] [-MacAddress <String>]
 [-EnableFilter <String>] [-Properties <Hashtable>] [-ShowDialog] [<CommonParameters>]
```

## DESCRIPTION

The `Find-XProtectDevice` cmdlet finds devices and provides the names of the parent hardware and recording server to help quickly locate devices by name. If searching for a child of a hardware object such as a camera or microphone, the name of the device(s) as well as their parent hardware object and recording server will be returned. When searching for a hardware object, only the hardware and recording server names will be returned.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.2

## EXAMPLES

### EXAMPLE 1

```powershell
Find-XProtectDevice -ItemType Hardware -Properties @{ Address = '192.168.1.101' }
```

Finds all hardware devices on all recording servers where the Address contains the IP '192.168.1.101'

### EXAMPLE 2

```powershell
Find-XProtectDevice -ItemType Camera -Name Parking
```

Finds all cameras with the word 'Parking' appearing in the name and returns the camera names, and parent hardware and recording server names.
The Name parameter is not case sensitive and does not support wildcards.

## PARAMETERS

### -Address

Specifies all or part of the IP or hostname of the hardware device to search for.

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

### -EnableFilter

Specifies whether all devices should be returned, or only enabled or disabled devices.
Default is to return all matching devices.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: All, Disabled, Enabled

Required: False
Position: Named
Default value: All
Accept pipeline input: False
Accept wildcard characters: False
```

### -ItemType

Specifies the ItemType such as Camera, Microphone, or InputEvent.
Default is 'Camera'.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Hardware, Camera, Microphone, Speaker, InputEvent, Output, Metadata

Required: False
Position: Named
Default value: Camera
Accept pipeline input: False
Accept wildcard characters: False
```

### -MacAddress

Specifies all or part of the MAC address of the hardware device to search for. Note: Searching by MAC is significantly slower than searching by IP.

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

### -Name

Specifies name, or part of the name of the device(s) to find.

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

### -Properties

Specifies an optional hash table of key/value pairs matching properties on the items you're searching for.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowDialog

Opens a UI dialog that provides a visual way of searching for a device. If using '-ShowDialog', no other parameters need to be specified on the command line. The results of the search will be outputted to the UI dialog, as opposed to the console.

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

## OUTPUTS

## NOTES

This function depends on Find-ConfigurationItem which is only supported on VMS versions from 2020 R2 and later.

## RELATED LINKS
