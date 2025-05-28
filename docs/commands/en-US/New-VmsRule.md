---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsRule/
schema: 2.0.0
---

# New-VmsRule

## SYNOPSIS
Creates a new rule with the provided name and properties.

## SYNTAX

```
New-VmsRule [-Name] <String> -Properties <Hashtable> [-Enabled <Boolean>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

The `New-VmsRule` cmdlet creates a new rule with the provided name and
properties. Creating rules in Milestone using Configuration API is similar to
creating rules in the Management Client. You start with a name and optional
description, and then submit these properties. In response, more properties are
received. The properties are filled and submitted in multiple iterations much
like stepping through a wizard in Management Client.

This cmdlet accepts a single, complete collection of properties, and goes through
the process of adding a new rule until the Management Server finally returns
an `InvokeResult` object with the ID of the newly created rule, or an error
message.

Since rules can have a wide variety of triggers, conditions, and actions,
each with their own unique property keys and value types, the best way to
discover the property keys and values you will need is to create a rule in
management client by hand, and then inspect that rule from PowerShell using
`Get-VmsRule`. The `Properties` collection of the rule returned by `Get-VmsRule`
can be used as a template when constructing your own rules.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 20.1

## EXAMPLES

### EXAMPLE 1
```powershell
Get-VmsRule | Get-Random | Foreach-Object {
    $_ | New-VmsRule -Name "Copy of $($_.DisplayName)"
}
```

Gets an existing rule at random and creates a copy by passing the Properties of
the existing rule by property name from the pipeline, and supplying a name for
the new rule.

### EXAMPLE 2
```powershell
<#
You can use the following command to see the property keys and values for an
existing rule. That is how the properties for this example were constructed.

Get-VmsRule -Name 'Default Record on Motion Rule' | Select-Object -ExpandProperty Properties
#>
$ruleParams = @{
    Name       = 'Copy of Default Record on Motion Rule'
    Properties = @{
        'Description'                    = 'Created from PowerShell using MilestonePSTools'
        'StartRuleType'                  = 'Event'
        'StartEventGroup'                = 'DevicePredefined'
        'StartEventType'                 = '6eb95dd6-7ccc-4bce-99f8-af0d0b582d77'
        'StartEventSources'              = 'CameraGroup[0e1b0ad3-f67c-4d5f-b792-4bd6c3cf52f8]'
        'StartActions'                   = 'StartRecording'
        'Start.StartRecording.Delay'     = '-3'
        'Start.StartRecording.DeviceIds' = 'Camera[00000000-0000-0000-0000-000000000000]'
        'StopRuleType'                   = 'Event'
        'StopEventGroup'                 = 'DevicePredefined'
        'StopEventType'                  = '6f55a7a7-d21c-4629-ac18-af1975e395a2'
        'StopEventSources'               = 'CameraGroup[0e1b0ad3-f67c-4d5f-b792-4bd6c3cf52f8]'
        'StopActions'                    = 'StopRecording'
        'Stop.StopRecording.Delay'       = '3'
    }
}
New-VmsRule @ruleParams
```

Creates a new copy of the rule named "Default Record on Motion Rule" which is
present in all VMS installations by default. The `Properties` hashtable was
created by copying the values returned by `Get-VmsRule -Name 'Default Record on Motion Rule' | Select-Object -ExpandProperty Properties`.

### Example 3

```powershell
$genericEvent = Get-GenericEvent | Where-Object Name -eq 'MilestonePSTools Test Generic Event'
if ($null -eq $genericEvent) {
    $datasource = Get-GenericEventDataSource | Where-Object Name -eq 'International'
    $datasource.Enabled = $true
    $datasource.Save()
    $genericEvent = Add-GenericEvent -Name 'MilestonePSTools Test Generic Event' -Expression '"Test Expression"' -ExpressionType Match -DataSourceId $datasource.Path
}

$newRuleParams = @{
    Name       = 'MilestonePSTools Example Rule on Generic Event'
    Properties = @{
        'Description'                    = 'Rule is triggered by a generic event and creates a Rule Log entry.'
        'StartRuleType'                  = 'Event'
        'StartEventGroup'                = 'GenericEvents'

        # The expected value is the GUID of an internal object representing a hidden user-defined event used to represent
        # a generic event rule match. There is no way for you to know ahead of time what the ID for this internal event
        # is. The ValueTypeInfos collection for the StartEventType has the generic event name and this hidden
        # user-defined event ID, and the New-VmsRule cmdlet will attempt to find the correct value from the
        # ValueTypeInfos collection if you provide the display name of an event instead of the ID.
        'StartEventType'                 = $genericEvent.Name
        'StartEventSources'              = 'External[e8bd6cee-1119-4296-ba91-e3803e2c591e]'
        'StopRuleType'                   = 'None'
        'Always'                         = 'False'
        'WithinTimeProfile'              = 'False'
        'WithinTimeProfile.TimeProfile'  = ''
        'OutsideTimeProfile'             = 'False'
        'OutsideTimeProfile.TimeProfile' = ''
        'TimeOfDayBetween'               = 'False'
        'TimeOfDayBetween.StartTime'     = '08:00:00'
        'TimeOfDayBetween.EndTime'       = '08:00:00'
        'DaysOfWeek'                     = 'False'
        'DaysOfWeek.Days'                = ''
        'StartActions'                   = 'CreateLogEntry'
        'Start.CreateLogEntry.Text'      = 'A generic event has been triggered'
    }
}
New-VmsRule @newRuleParams
```

Creates a rule based on a generic event which logs a message to the rule log.
A generic event data source is enabled if necessary, then the generic event is
created. Under the hood, generic events are represented by a shadow
"user-defined event" and there's no API available for figuring out the
underlying ID for the event triggered when a generic event rule is matched with
data from an incoming TCP/UDP stream.

When creating a rule, you are presented with a collection of properties with a
key, maybe a default value, and for Enum value types, a collection of "ValueTypeInfos"
which describe a set of valid options to choose from.

If you supply the display name instead of a valid value, the `New-VmsRule` cmdlet
will automatically compare the value to provided with the display names of the
ValueTypeInfos for that property, and if a match is found, the display name you
provided will be substituted for the internal value accepted by the Management
Server. In the verbose message stream you will see a message like "Value for
user-supplied property 'StartEventType' has been mapped from 'MilestonePSTools
Test Generic Event' to '3c55a424-d341-4781-a806-dfb60d46789e'".

### Example 4

```powershell
$testUserDefinedEvent = (Get-VmsManagementServer).UserDefinedEventFolder.UserDefinedEvents | Where-Object Name -eq 'MilestonePSTools Test Event'
if ($null -eq $testUserDefinedEvent) {
    $invokeResult = (Get-VmsManagementServer).UserDefinedEventFolder.AddUserDefinedEvent('MilestonePSTools Test Event')
    $testUserDefinedEvent = (Get-VmsManagementServer).UserDefinedEventFolder.UserDefinedEvents | Where-Object Path -eq $invokeResult.Path
}

$newRuleParams = @{
    Name       = 'MilestonePSTools Example Rule on User Defined Event'
    Properties = @{
        'Description'                    = 'Rule is triggered by a user defined event and creates a Rule Log entry.'
        'StartRuleType'                  = 'Event'
        'StartEventGroup'                = 'UserDefinedEvents'
        'StartEventType'                 = $testUserDefinedEvent.Id
        'StartEventSources'              = 'External[e8bd6cee-1119-4296-ba91-e3803e2c591e]'
        'StopRuleType'                   = 'None'
        'Always'                         = 'False'
        'WithinTimeProfile'              = 'False'
        'WithinTimeProfile.TimeProfile'  = ''
        'OutsideTimeProfile'             = 'False'
        'OutsideTimeProfile.TimeProfile' = ''
        'TimeOfDayBetween'               = 'False'
        'TimeOfDayBetween.StartTime'     = '08:00:00'
        'TimeOfDayBetween.EndTime'       = '08:00:00'
        'DaysOfWeek'                     = 'False'
        'DaysOfWeek.Days'                = ''
        'StartActions'                   = 'CreateLogEntry'
        'Start.CreateLogEntry.Text'      = 'User defined event has been triggered'
    }
}
New-VmsRule @newRuleParams
```

Creates a user-defined event, and then a rule to log a message in the rule log
when the user-defined event is triggered.

## PARAMETERS

### -Enabled
Specifies whether the rule should be enabled.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: EnableProperty

Required: False
Position: Named
Default value: True
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies a name for the new rule.

```yaml
Type: String
Parameter Sets: (All)
Aliases: DisplayName

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Properties
Specifies a collection of properties either as a hashtable, or as list of
objects, each having a Key and a Value property. For example, you can pass in
the `Properties` collection from the result of `Get-VmsRule` and the Key/Value
properties from each of the properties in the collection will be automatically
converted to a hashtable when calling `New-VmsRule`.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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

## OUTPUTS

### VideoOS.ConfigurationApi.ClientService.ConfigurationItem

## NOTES

## RELATED LINKS
