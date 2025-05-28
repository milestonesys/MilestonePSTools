---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-DeviceAcl/
schema: 2.0.0
---

# Set-DeviceAcl

## SYNOPSIS

Applies the specified device permissions.

## SYNTAX

```
Set-DeviceAcl -DeviceAcl <DeviceAcl> [<CommonParameters>]
```

## DESCRIPTION

The `Set-DeviceAcl` cmdlet applies any changes made to a `DeviceAcl` object
returned by a prior call to `Get-DeviceAcl`. This is used to update the
permissions for a given role on a specific device.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
$camera = Get-VmsCamera | Select-Object -First 1
$role = Get-VmsRole -RoleType UserDefined | Select-Object -First 1
$acl = Get-DeviceAcl -Camera $camera -Role $role
$acl.SecurityAttributes.GENERIC_READ = 'True'
$acl | Set-DeviceAcl
```

Grants "read" permission for a camera to a role.

## PARAMETERS

### -DeviceAcl

Specifies a DeviceAcl object returned by `Get-DeviceAcl`.

```yaml
Type: DeviceAcl
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

### MilestoneLib.DeviceAcl

## OUTPUTS

### None

## NOTES

## RELATED LINKS
