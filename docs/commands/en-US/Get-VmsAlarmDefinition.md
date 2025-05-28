---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsAlarmDefinition/
schema: 2.0.0
---

# Get-VmsAlarmDefinition

## SYNOPSIS
Gets alarm definitions from the Event Server.

## SYNTAX

```
Get-VmsAlarmDefinition [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsAlarmDefinition` cmdlet gets Alarm Definitions from the Event Server. When used without the `-Name`
parameter it will return all alarm definitions. When used with the `-Name` parameter, the definitions will be filtered
with support for wildcards.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
$columns = @(
    'Name',
    @{
        Name = 'EventGroup'
        Expression = {
            $def = $_
            $def.EventTypeGroupValues.Keys | Where-Object {
                $def.eventtypegroupvalues[$_] -eq $def.EventTypeGroup
            }
        }
    },
    @{
        Name = 'Event'
        Expression = {
            $def = $_
            $def.EventTypeValues.Keys | Where-Object {
                $def.eventtypevalues[$_] -eq $def.EventType
            }
        }
    }
)

Get-VmsAlarmDefinition | Select-Object $columns
```

Gets a list of all configured alarm definitions, and returns the Name, and triggering EventGroup and Event names. This
example uses "calculated properties" to convert the `EventTypeGroup` and `EventType` `[Guid]` values to human readable
names by retrieving those names from the `EventTypeGroupValues` and `EventTypeValues` dictionaries attached to every
alarm definition.

### Example 2

```powershell
Get-VmsAlarmDefinition Camera*
```

Gets a list of all alarm definitions with a name starting with the word "Camera".

## PARAMETERS

### -Name
Specifies the alarm definition name, or a part of the name with support for wildcards.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: True
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.AlarmDefinition

## NOTES

## RELATED LINKS
