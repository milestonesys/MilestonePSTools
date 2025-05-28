---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Join-VmsDeviceGroupPath/
schema: 2.0.0
---

# Join-VmsDeviceGroupPath

## SYNOPSIS
Joins an array of strings into a valid device group path with escaped
forward-slashes as needed.

## SYNTAX

```
Join-VmsDeviceGroupPath [-PathParts] <String[]> [<CommonParameters>]
```

## DESCRIPTION
This cmdlet can be used to safely construct a device group path from an
array of names representing the device group hierarchy.
Any unescaped
forward-slashes will be automatically escaped for you in the return value.

For example, the string "/People Counting/Entrances\`/Exits" could represent
a camera group named "Entrances/Exits" in a parent group named
"People Counting", using the device group path format implemented by
MilestonePSTools.

This device group path can be safely constructed using the individual group
names, without concern over how to escape any unescaped forward-slashes.
If
a forward-slash is intended to be a part of a device group name and the
device group is created using \`New-VmsDeviceGroup -Path\`, then an unescaped
forward-slash will end up splitting that device group name into two parts,
and you will have an unexpected subgroup.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1
```powershell
'People Counting', 'Entrances/Exits' | Join-VmsDeviceGroupPath
```

This example constructs a device group path like \`/People Counting/Entrances\`/Exits\`.
Note the backtick added before "/Exits".
Without the backtick, creating a
device group with this path would result in a total of three device groups
with a "leaf" group named "Exits".
This cmdlet joined the parts of the path
and escaped the previously unescaped directory separator character "/" with
a backtick to signal that the forward slash is a part of the device group
name instead of a directory separator.

## PARAMETERS

### -PathParts
Specifies a hierarchy of device group names to use to construct a device
group path with a unix directory-style path format.
The order of strings is
important: the first string represents the "root" device group, and the
last string represents the "leaf" device group.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES

## RELATED LINKS
