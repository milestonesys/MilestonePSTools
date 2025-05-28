---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsCamera/
schema: 2.0.0
---

# Get-VmsCamera

## SYNOPSIS
Gets the matching camera records from the Milestone XProtect Management Server.

## SYNTAX

### QueryItems (Default)
```
Get-VmsCamera [[-Name] <String>] [[-Description] <String>] [[-Channel] <Int32[]>]
 [[-EnableFilter] <EnableFilter>] [[-Comparison] <Operator>] [[-MaxResults] <Int32>] [<CommonParameters>]
```

### Hardware
```
Get-VmsCamera [-Hardware] <Hardware[]> [[-Name] <String>] [[-Description] <String>] [[-Channel] <Int32[]>]
 [[-EnableFilter] <EnableFilter>] [[-Comparison] <Operator>] [<CommonParameters>]
```

### Id
```
Get-VmsCamera [-Id] <Guid[]> [<CommonParameters>]
```

### Path
```
Get-VmsCamera [-Path] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Uses Milestone's Configuration API to retrieve matching camera records. The
objects returned are read/write representations of the matching cameras. You may
use these for reporting purposes, or for changing configuration properties.

To change properties on the camera records, you may directly modify the value of
properties, or you may use the Set-VmsCamera cmdlet. When directly modifying the
object's properties, you must call the ".Save()" method, or the changes will not
be communicated to the Management Server.

By default, this cmdlet only returns enabled cameras. To return cameras that are
disabled, or to return all cameras, use the EnableFilter parameter to set your
preference.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Connect-Vms -ShowDialog -AcceptEula
Get-VmsCamera

<# OUTPUT
Name                                                      Channel Enabled LastModified          Id
----                                                      ------- ------- ------------          --
Axis A8105-E (10.1.77.153) - Camera 1                     0       True    1/15/2022 12:22:27 PM 3DCCE3DA-021D-4968-831C-24F09031EEDA
Axis M1125 (10.1.77.129) - Camera 1                       0       True    1/15/2022 11:29:10 AM 44E1D43D-4A54-4B8A-8E3D-513EB7007AAC
Axis P1375 (10.1.77.178) - Camera 1                       0       True    1/15/2022 11:22:44 AM DD9F523E-AFB2-4E6F-A11D-262A4E760B5A
Axis P3225-LV (10.1.77.130) - Camera 1                    0       True    1/15/2022 11:22:48 AM 71D46BAA-9810-45B0-8461-DD5B369FFB0B
#>
```

In this example, we first ensure we are logged in to the Management Server. Then
we call the "Get-VmsCamera" cmdlet with no parameters which will return all
enabled cameras. By piping these results to "Out-GridView" we can view the
output in a sortable, searchable table.

### Example 2
```powershell
Get-VmsCamera -Name 'Garage'

<# OUTPUT
Name           Channel Enabled LastModified         Id
----           ------- ------- ------------         --
Garage Camera  0       True    1/18/2022 3:41:21 PM CA146DFD-72C9-4BBA-83DD-8B680E70DA1B
#>
```

This example demonstrates how to find all enabled cameras with the word "Garage"
anywhere in the camera name. The search is case-insensitive and will return
cameras named "Shop Garage" or "Rear garage door".

### Example 3
```powershell
Get-VmsCamera -Name 'Garage' -EnableFilter All

<# OUTPUT
Name     Channel Enabled LastModified         Id
----     ------- ------- ------------         --
Garage 1 0       True    12/1/2021 4:23:24 PM 430FA37D-CBE6-4248-9CBA-989AEF7F0428
Garage 2 1       False   1/13/2022 1:27:42 PM 22436AA5-CC64-4F82-A35C-3EF9ADEFED74
Garage 3 0       True    1/17/2022 4:32:00 PM 80DA2327-D178-457A-8216-0F7D6CF2F746
#>
```

Find all cameras, enabled or disabled, with the word "Garage" anywhere in the
camera name. The search is case-insensitive, and uses a fast search feature
introduced in XProtect 2020 R2.

### Example 4
```powershell
Get-VmsHardware | Where-Object Name -like '*Elevator*' | Get-VmsCamera -EnableFilter All

<# OUTPUT
Name           Channel Enabled LastModified         Id
----           ------- ------- ------------         --
North Elevator 0       True    1/18/2022 3:41:21 PM CA146DFD-72C9-4BBA-83DD-8B680E70DA1B
#>
```

Find all hardware where the word "elevator" appears in the name, and then return
all camera channels associated with those hardware devices, both enabled and
disabled.

### Example 5
```powershell
Get-VmsCamera -Id '42C055AA-3EAC-45AF-B956-5C253384BDF1'

<# OUTPUT
Name           Channel Enabled LastModified         Id
----           ------- ------- ------------         --
Garage Cam 1   0       True    1/18/2022 3:41:21 PM 42C055AA-3EAC-45AF-B956-5C253384BDF1
#>
```

Returns one camera matching the supplied ID.

### Example 6
```powershell
(Get-ItemState -CamerasOnly | Where-Object State -ne 'Responding').FQID.ObjectId | Get-VmsCamera

<#
Name                      Channel Enabled LastModified          Id
----                      ------- ------- ------------          --
Canon VB-M40 - Camera 1   0       True    12/7/2021 3:37:23 PM  3E337A3D-8C48-4B9E-A61A-972CDD261B27
Canon VB-S900F - Camera 1 0       True    12/7/2021 3:04:59 PM  539FDA6D-1167-4C3D-854D-577B60FEAB88
#>
```

Retrieves the state of all enabled cameras, and extracts the ID of all cameras
that are not responding, according to the Milestone Event Server. These camera
ID's are then used to retrieve the camera configuration records for these cameras.

### Example 7
```powershell
Get-VmsHardware | Get-VmsCamera -Channel (1..15)

<# OUTPUT
Name   Channel Enabled LastModified         Id
----   ------- ------- ------------         --
TH6TC2 1       True   1/17/2022 4:32:00 PM 96F49AF3-861C-4037-8950-8B933644E861
TH6TC3 2       True   1/17/2022 4:32:00 PM 8A175713-823A-46EF-A0E4-1768EA7A5A04
TH6TC4 3       True   1/17/2022 4:32:00 PM C958EE67-4C72-4884-A77F-A3882FB12F97
#>
```

Returns all enabled cameras from all hardware devices where the channel number is
between 1 and 15, representing camera 2 through camera 16. You might use this if
you only want the first channel enabled, and you want to use the results of this
query to disable unwanted camera channels.

## PARAMETERS

### -Channel
Specifies the camera channel number, or numbers, to return. Numbering starts at
zero, so channel 0 corresponds to the first camera on the hardware device.

```yaml
Type: Int32[]
Parameter Sets: QueryItems, Hardware
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Comparison
Specifies the type of string comparison to perform when searching by name, or
description. By default, cameras will be returned if the camera name contains
the values specified in the Name or Description parameters anywhere in the
string, and the comparison will be case-insensitive.

```yaml
Type: Operator
Parameter Sets: QueryItems, Hardware
Aliases:
Accepted values: Equals, NotEquals, LessThan, GreaterThan, Contains, BeginsWith

Required: False
Position: 4
Default value: Contains
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
Specifies a camera description, or any part of a camera description to search
for. Any cameras with a matching description will be returned. The default
behavior is to return cameras where the supplied value appears anywhere in the
camera's description. You may change this behavior by providing an alternate
comparison operator using the Comparison parameter.

Please note that if you supply both a Name and a Description value, the search
results returned will include only cameras where the name and description both
match the query.

```yaml
Type: String
Parameter Sets: QueryItems, Hardware
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableFilter
Specifies whether to return enabled, disabled, or all cameras when querying by
hardware or searching by name or description. The default is to return only
enabled cameras.

```yaml
Type: EnableFilter
Parameter Sets: QueryItems, Hardware
Aliases:
Accepted values: All, Enabled, Disabled

Required: False
Position: 3
Default value: Enabled
Accept pipeline input: False
Accept wildcard characters: False
```

### -Hardware
Specifies the hardware object from which to return matching cameras. Results
can be filtered further by providing values for one or more additional parameters.

```yaml
Type: Hardware[]
Parameter Sets: Hardware
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Id
Specifies one or more camera ID's in GUID format. All cameras matching the
supplied GUID's will be returned.

```yaml
Type: Guid[]
Parameter Sets: Id
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -MaxResults
Specifies the maximum number of results to return when searching by name or
description. By default, the maximum number of results is 2147483647.

```yaml
Type: Int32
Parameter Sets: QueryItems
Aliases:

Required: False
Position: 5
Default value: [int]::MaxValue
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies a camera name, or any part of a camera name to search
for. Any cameras with a matching name will be returned. The default
behavior is to return cameras where the supplied value appears anywhere in the
camera's name. You may change this behavior by providing an alternate
comparison operator using the Comparison parameter.

Please note that if you supply both a Name and a Description value, the search
results returned will include only cameras where the name and description both
match the query.

```yaml
Type: String
Parameter Sets: QueryItems, Hardware
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
The Milestone Configuration API string representing the device in the format `DeviceType[DeviceId]`.

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Hardware[]

### System.Int32[]

### System.Guid

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.Camera

## NOTES

## RELATED LINKS
