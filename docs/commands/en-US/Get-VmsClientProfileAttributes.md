---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsClientProfileAttributes/
schema: 2.0.0
---

# Get-VmsClientProfileAttributes

## SYNOPSIS
Gets the attributes for the specified smart client profile.

## SYNTAX

```
Get-VmsClientProfileAttributes -ClientProfile <ClientProfile> [[-Namespace] <String[]>] [-ValueTypeInfo]
 [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsClientProfileAttributes` cmdlet gets the attributes for the specified
smart client profile. Smart client profiles have several different categories
of attributes or settings which are called "namespaces" in this PowerShell module
which should be familiar if you have used the `Get-VmsRoleOverallSecurity` cmdlet.

If no value is provided for the `Namespace` parameter, then a dictionary will be
returned for all available namespaces. Each dictionary will contain a key named
"Namespace" to help identify which namespace the attributes are from. The remaining
keys will match the available attribute names for that client profile namespace.

The values for each of the attributes will be a `[PSCustomObject]` with three
properties: Value, ValueTypeInfo, and Locked.

"Value" is the string value of that attribute. "ValueTypeInfo" will be `$null` by
default, or an array of type [VideoOS.ConfigurationApi.ClientService.ValueTypeInfo[]]
if the `ValueTypeInfo` switch is specified. The ValueTypeInfo array can be used
as a reference to know what the valid options are for a given attribute. Finally,
the "Locked" property will be one of either `$null`, `$true`, or `$false`. If the
smart client profile attribute shows a checkbox option in the Management Client,
then the value should be `$true` if currently checked or "locked", and `$false`
if currently unchecked. If there is no checkbox in Management Client, then the
value will be `$null`. This normally means the attribute doesn't represent a
setting that is possible to change in Smart Client.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 21.2
- Requires VMS feature "SmartClientProfiles"

## EXAMPLES

### Example 1
```powershell
Get-VmsClientProfile | Foreach-Object {
    $general = $_ | Get-VmsClientProfileAttributes -Namespace General
    [pscustomobject]@{
        Name      = $_.Name
        StartView = $general.ApplicationStartView.Value
    }
}
<# OUTPUT
Name                         StartView
----                         ---------
Operator Profile             Last
Default Smart Client Profile Last
#>
```

Returns a `[pscustomobject]` with the name of every smart client profile and the
value of the "ApplicationStartView" attribute in namespace "General".

### Example 2
```powershell
Get-VmsClientProfile | Foreach-Object {
    $general = $_ | Get-VmsClientProfileAttributes -Namespace General -ValueTypeInfo
    [pscustomobject]@{
        Name      = $_.Name
        StartView = $general.ApplicationStartView.Value
        Options   = $general.ApplicationStartView.ValueTypeInfo.Value -join '|'
    }
}

<# OUTPUT
Name                         StartView Options
----                         --------- -------
Operator Profile             Last      Last|None|Ask
Default Smart Client Profile Last      Last|None|Ask
#>
```

### Example 3
```powershell
(Get-VmsClientProfile -DefaultProfile | Get-VmsClientProfileAttributes).Namespace

<# OUTPUT
AccessControl
Advanced
AlarmManager
Export
General
GisMap
Live
Playback
Setup
Timeline
ViewLayouts
#>
```

Returns a list of all the available smart client profile attribute namespaces by
retrieving all attributes from the default client profile and returning the value
behind the "Namespace" key from each attribute dictionary.

## PARAMETERS

### -ClientProfile
Specifies a smart client profile. The value can be either a ClientProfile object
as returned by Get-VmsClientProfile, or it can be the name of an existing
client profile.

```yaml
Type: ClientProfile
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Namespace
Specifies one or more existing client profile attribute namespaces. If omitted,
attributes from all namespaces will be returned. This parameter can be tab-completed
when used interactively.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ValueTypeInfo
Include ValueTypeInfo data, if available, for each attribute.

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

### VideoOS.Platform.ConfigurationItems.ClientProfile

## OUTPUTS

### System.Collections.IDictionary

## NOTES

## RELATED LINKS
