---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsHardware/
schema: 2.0.0
---

# Set-VmsHardware

## SYNOPSIS
Updates one or more properties of a hardware device.

## SYNTAX

```
Set-VmsHardware [-Hardware] <Hardware[]> [[-Enabled] <Boolean>] [[-Name] <String>] [[-Address] <Uri>]
 [[-UserName] <String>] [[-Password] <SecureString>] [-UpdateRemoteHardware] [[-Description] <String>]
 [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsHardware` cmdlet updates one or more properties of a hardware device
including name, address, username, password, description, and whether or not the
hardware should be enabled.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
$password = Read-Host -Prompt 'Password for hardware' -AsSecureString
foreach ($hw in Get-VmsHardware) {
    $hw | Set-VmsHardware -Enabled $true -UserName 'vms' -Password $password -WhatIf
    foreach ($cam in $hw | Get-VmsCamera -EnableFilter All) {
        $cam | Set-VmsCamera -Enabled ($cam.Channel -eq 0) -WhatIf
    }
}
```

In this example we prompt for a new password for the VMS to use with all hardware.
Next, all hardware is enabled and the username and password is updated (in the VMS only),
and we ensure only the first camera channel (channel 0) is enabled on every device.
Because of the presence of the `-WhatIf` parameter, you will see what would happen
without making any modifications.

### Example 2
```powershell
Get-VmsHardware -PipelineVariable hw | Foreach-Object {
    $hostAddress = (([uri]$hw.Address).Host -split '\.')[-1]
    $hw | Set-VmsHardware -Address "http://172.16.100.$hostAddress" -WhatIf -Verbose
}
```

This example demonstrates one way you might update the IP addresses of all cameras
in the VMS if, for example, the network subnet changed from 192.168.1.0/24 to
172.16.100.0/24, and the 4th octet for all cameras will remain the same, but the
first three octets must be updated to match the new subnet.

The example assumes all camera addresses are currently set to an IPv4 address, splits
the IP address for each hardware by the "." separating the octets, and stores the
last octet in the `$hostAddress` variable. The new address for all cameras will
start with "http://172.16.100." followed by the value of `$hostAddress`.

Because the `-WhatIf` parameter is present, no change will be made to the hardware
settings in the VMS.

## PARAMETERS

### -Address
Specifies the new hardware address in URI format. For example: http://192.168.1.101,
or http://192.168.1.101:8080 when using a non-default HTTP port.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Specifies a new value for the hardware description.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Enabled
Specifies whether the hardware should be enabled or disabled. Provide `$true` to
enable the hardware if it is not already enabled, and `$false` to disable the hardware
if it is not already disabled.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hardware
Specifies the hardware object to modify. Use Get-VmsHardware to retrieve hardware
objects.

```yaml
Type: Hardware[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
Specifies a new value for the hardware name.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return the hardware object to the pipeline.

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

### -Password
Specifies a new hardware password. If the password is supplied as a plain text
string, it will automatically be converted to a `[securestring]`. Note that extra
care should be used if passwords are exposed in plain text in a terminal,
powershell command history, or files on disk.

REQUIREMENTS  

- Requires VMS version 11.3

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases: NewPassword

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UpdateRemoteHardware
Specifies that the value provided in the Password parameter will be used to update the password both in the Milestone
VMS and on the remote hardware device. Note that the hardware and device pack driver must support password changes on
the device, and Milestone requires passwords to be a maximum of 64 characters with at least one upper-case character,
one lower-case character, and one number. Only the characters a-z, A-Z, and numbers 0.9 are allowed.

REQUIREMENTS  

- Requires VMS version 23.2

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

### -UserName
Specifies a new UserName value to use to authenticate with the hardware device.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Hardware[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Hardware

## NOTES

## RELATED LINKS
