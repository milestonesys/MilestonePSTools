---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsHardwarePassword/
schema: 2.0.0
---

# Get-VmsHardwarePassword

## SYNOPSIS
Gets the password used by the VMS to authenticate with the hardware.

## SYNTAX

```
Get-VmsHardwarePassword [-Hardware] <Hardware> [<CommonParameters>]
```

## DESCRIPTION
Gets the password used by the VMS to authenticate with the hardware.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsHardware | Foreach-Object {
    [pscustomobject]@{
        Address  = $_.Address
        UserName = $_.UserName
        Password = $_ | Get-VmsHardwarePassword
    }
}
```

Gets the address, username, and password for all hardware on all recording servers.

## PARAMETERS

### -Hardware
Specifies the hardware for which to retrieve the password.

```yaml
Type: Hardware
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Hardware

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
