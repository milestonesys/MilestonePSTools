---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Split-VmsDeviceGroupPath/
schema: 2.0.0
---

# Split-VmsDeviceGroupPath

## SYNOPSIS
Splits a "unix-style" device group path into an array of strings representing each node in the hierarchy.

## SYNTAX

```
Split-VmsDeviceGroupPath [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Splits a "unix-style" device group path into an array of strings representing each node in the hierarchy.

The *VmsDeviceGroup cmdlets implement their own method of describing a Milestone
device group hierarchy which simplifies automation. The Split-VmsDeviceGroupPath
and Resolve-VmsDeviceGroupPath cmdlets are provided as utility functions for
performing operations on device groups to determine their "path" or to split a
path up to perform your own operations as needed.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1
```powershell
Split-VmsDeviceGroupPath -Path "/Level 1/Level 2/Level 3"
```

Splits the specified path into the parts "Level 1", "Level 2", and "Level 3"

### Example 2
```powershell
Split-VmsDeviceGroupPath -Path '/Group/Subgroup1`/Childgroup/Subgroup2'
```

Splits the specified path into the parts "Group", "Subgroup1/Childgroup", and "Subgroup2".
Note the use of the "backtick" symbol as an escape character for the forward-slash
between "Subgroup1" and "Childgroup". If a device group needs to have a forward-slash
symbol in the name, it needs to be escaped in PowerShell so that the *VmsDeviceGroup* cmdlets
understand that it isn't supposed to be a path separator.

## PARAMETERS

### -Path
Specifies a full unix-style path to the desired device group. See the examples
for reference.

```yaml
Type: String
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

### System.String

## OUTPUTS

### System.String[]

## NOTES

## RELATED LINKS
