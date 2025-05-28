---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-DeviceAcl/
schema: 2.0.0
---

# Get-DeviceAcl

## SYNOPSIS

Gets the device permissions associated with the specified role.

## SYNTAX

### FromCamera
```
Get-DeviceAcl -Camera <Camera> [[-RoleName] <String>] [-RoleId <Guid>] [-Role <Role>] [<CommonParameters>]
```

### FromMicrophone
```
Get-DeviceAcl -Microphone <Microphone> [[-RoleName] <String>] [-RoleId <Guid>] [-Role <Role>]
 [<CommonParameters>]
```

### FromSpeaker
```
Get-DeviceAcl -Speaker <Speaker> [[-RoleName] <String>] [-RoleId <Guid>] [-Role <Role>] [<CommonParameters>]
```

### FromInput
```
Get-DeviceAcl -Input <InputEvent> [[-RoleName] <String>] [-RoleId <Guid>] [-Role <Role>] [<CommonParameters>]
```

### FromOutput
```
Get-DeviceAcl -Output <Output> [[-RoleName] <String>] [-RoleId <Guid>] [-Role <Role>] [<CommonParameters>]
```

### FromMetadata
```
Get-DeviceAcl -Metadata <Metadata> [[-RoleName] <String>] [-RoleId <Guid>] [-Role <Role>] [<CommonParameters>]
```

### FromHardware
```
Get-DeviceAcl -Hardware <Hardware> [[-RoleName] <String>] [-RoleId <Guid>] [-Role <Role>] [<CommonParameters>]
```

## DESCRIPTION

The `Get-DeviceAcl` cmdlet applies gets the device permissions associated with
the specified role. These permissions can be changed on the SecurityAttributes
property and updated on the VMS using `Set-DeviceAcl`.

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

### -Camera

Grants "read" permission for a camera to a role.

```yaml
Type: Camera
Parameter Sets: FromCamera
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Hardware

Specifies a hardware object such as the objects returned from `Get-VmsHardware`.
A collection of permissions from all child devices will be returned.

```yaml
Type: Hardware
Parameter Sets: FromHardware
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Input

Specifies an input device channel.

```yaml
Type: InputEvent
Parameter Sets: FromInput
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Metadata

Specifies a metadata device channel.

```yaml
Type: Metadata
Parameter Sets: FromMetadata
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Microphone

Specifies a microphone device channel.

```yaml
Type: Microphone
Parameter Sets: FromMicrophone
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Output

Specifies an output device channel.

```yaml
Type: Output
Parameter Sets: FromOutput
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Role

Specifies a role object such as is returned by `Get-VmsRole`.

```yaml
Type: Role
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RoleId

Specifies the ID of an existing role.

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RoleName

Specifies the name of an existing role.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Speaker

Specifies a speaker device channel.

```yaml
Type: Speaker
Parameter Sets: FromSpeaker
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

### VideoOS.Platform.ConfigurationItems.IConfigurationItem

## OUTPUTS

### MilestoneLib.DeviceAcl

## NOTES

## RELATED LINKS
