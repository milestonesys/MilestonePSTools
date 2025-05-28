---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Start-VmsHardwareScan/
schema: 2.0.0
---

# Start-VmsHardwareScan

## SYNOPSIS

Starts either an express, or a manual hardware scan on one or more recording servers

## SYNTAX

### Express
```
Start-VmsHardwareScan -RecordingServer <RecordingServer[]> [-Express] [-Credential <PSCredential[]>]
 [-UseDefaultCredentials] [-UseHttps] [-PassThru] [<CommonParameters>]
```

### Manual
```
Start-VmsHardwareScan -RecordingServer <RecordingServer[]> [-Address <Uri[]>] [-Start <IPAddress>]
 [-End <IPAddress>] [-Cidr <String>] [-HttpPort <Int32>] [-DriverNumber <Int32[]>] [-DriverFamily <String[]>]
 [-Credential <PSCredential[]>] [-UseDefaultCredentials] [-UseHttps] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION

The hardware scan process allows you to discover cameras using the "Express" parameter, or
check specific camera IPs or ranges to see if any cameras matching one or more drivers/credentials
are found.
The resulting VmsHardwareScanResult object contains all the information needed for
Add-VmsHardware to add the camera to the recording server.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsRecordingServer | Out-GridView -OutputMode Single | Start-VmsHardwareScan -Express
```

Prompts the user to select one Recording Server from a list, and then initiates an express hardware scan from that Recording Server.
The results when displayed in a PowerShell terminal will appear as follows.
Note that there are additional properties available that are
not displayed by the default formatter.

HardwareAddress                                   UserName MacAddress   Validated ExistsLocally ExistsGlobally RecordingServer
---------------                                   -------- ----------   --------- ------------- -------------- ---------------
http://192.168.1.1/                                admin   123456789123  True      True          False          TestServer
http://192.168.1.2/                                admin   123456789124  True      False         False          TestServer
http://192.168.1.3/                                admin   123456789125  False     False         False          TestServer

### EXAMPLE 2

```powershell
$recorder | Start-VmsHardwareScan -Start 192.168.1.1 -End 192.168.1.10 -DriverFamily Axis -Credential (Get-Credential), (Get-Credential) -UseDefaultCredentials
```

Prompts the user for two sets of credentials to try against a range of 10 cameras on the recording server in the $recorder variable.
All
drivers under the Axis group name will be tried.
A result for each address scanned will be returned to the pipeline even if no camera
was found.
The results will look similar to Example #1 for cameras that are found, while the entries for unresponsive IP addresses will
look like the following table.

HardwareAddress UserName MacAddress Validated ExistsLocally ExistsGlobally RecordingServer
--------------- -------- ---------- --------- ------------- -------------- ---------------
                                    False     False         False          TestServer
                                    False     False         False          TestServer
                                    False     False         False          TestServer

### EXAMPLE 3

```powershell
$recorder | Start-VmsHardwareScan -Cidr 192.168.1.0/30 -DriverNumber 707 -UseDefaultCredentials
```

A range of 4 IP addresses is defined using CIDR notation and the default driver credentials for the "Infinova G/T/H PTZ Series" driver
will be used against each IP.
The first and last IP of the CIDR range will be skipped since those represent the network address and
broadcast address for the subnet.

## PARAMETERS

### -Address

Specifies the IP or HTTP/HTTPS URI to scan.

```yaml
Type: Uri[]
Parameter Sets: Manual
Aliases:

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -Cidr

Specifies a range of IPv4 or IPv6 addresses to scan in CIDR notation.
Example: 192.168.1.0/24 for 192.168.1.1 - 192.168.1.254.

```yaml
Type: String
Parameter Sets: Manual
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential

Specifies the credential to use when scanning for cameras.

```yaml
Type: PSCredential[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriverFamily

Specifies a device driver group name or "family" such as "Axis", "Bosch" or "Milestone".
All applicable device driver ID's will be discovered automatically.

```yaml
Type: String[]
Parameter Sets: Manual
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DriverNumber

Specifies one or more Milestone device drivers to scan for.
It's recommended to always provide at least one driver and the fewer the better/faster the scan.

```yaml
Type: Int32[]
Parameter Sets: Manual
Aliases:

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

### -End

Specifies the end of an IPv4 or IPv6 range to scan.

```yaml
Type: IPAddress
Parameter Sets: Manual
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Express

Specifies that the Express hardware scan option should be used.
This can be considerably faster than a range scan, but it can also fail to discover cameras under certian network conditions.

```yaml
Type: SwitchParameter
Parameter Sets: Express
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -HttpPort

Specifies an alternate HTTP/HTTPS port to use in case you don't use the defaults of 80/443.

```yaml
Type: Int32
Parameter Sets: Manual
Aliases:

Required: False
Position: Named
Default value: 80
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru

Specifies that the Milestone "Tasks" should be returned to the pipeline immediately instead of the default behavior of waiting for all scan operations to complete and returning a VmsHardwareScanResult object.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -RecordingServer

Specifies one or more Recording Server objects on which to run hardware scans.
Scans on multiple recorders can be run in parallel.

```yaml
Type: RecordingServer[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Start

Specifies the start of an IPv4 or IPv6 range to scan.

```yaml
Type: IPAddress
Parameter Sets: Manual
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseDefaultCredentials

Specifies to use the driver default credentials if applicable.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseHttps

Specifies that a secure HTTPS connection should be made to cameras during the scan instead of an HTTP connection.
If you provide a full uri like https://192.168.1.1 in the Address parameter, then this property is redundant.
However if you choose to perform a range scan, this is how you would specify which HTTP scheme to use during the scan.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VmsHardwareScanResult

## NOTES

## RELATED LINKS
