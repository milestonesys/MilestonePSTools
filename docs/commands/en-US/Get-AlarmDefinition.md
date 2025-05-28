---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-AlarmDefinition/
schema: 2.0.0
---

# Get-AlarmDefinition

## SYNOPSIS

Gets Alarm Definitions from the Event Server.

## SYNTAX

```
Get-AlarmDefinition [[-Name] <String>] [<CommonParameters>]
```

## DESCRIPTION

Gets a list of Alarm Definitions from the Management Server / Event Server.
Effectively this is a simplified way to access (Get-VmsManagementServer).AlarmDefinitionFolder.AlarmDefinitions.

Note: Manipulation of Alarm Definitions is not fully supported in this module.
You can, however, manipulate alarm definitions retrieved from this cmdlet by making supported changes to the object, then calling the Save() method.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-AlarmDefinition
```

Gets all Alarm Definitions defined on the Event Server.
This should be the same list you would see in the Management Client.

### EXAMPLE 2

```powershell
Get-AlarmDefinition -Name *Overflow*
```

Gets all Alarm Definitions defined on the Event Server where the Name of the alarm contains "Overflow".

Alarms named "Feed Overflow Started" or "Overflows Detected" would be returned with this command.

### EXAMPLE 3

```powershell
$alarm = Get-AlarmDefinition -Name "Motion Detected"; $alarm.TriggerEventlist = 'UserDefinedEvent[a90f978f-9c28-4202-b7cc-4c232e8b17b4]'; $alarm.Save()
```

Gets an alarm named "Motion Detected", and changes the alarm settings such that a previously defined User-defined Event will be triggered when the alarm is triggered, then saves the changes using the Save() method.

You might trigger a user-defined event with an alarm in order to connect the alarm into the rules system to perform some other desired action.
Occasionally the source of an alarm is not available as a trigger in the rule system, so you can map an alarm into a rule in this way.

Note: If an Alarm Definition named 'Motion Detected' does not exist, an error will be thrown with exception ItemNotFoundException.

## PARAMETERS

### -Name

Specifies the Alarm Definition Name using a case-insensitive string with support for wildcards characters.

If Name is provided, does not contain wildcard characters, and no matching Alarm Definition is found, an error will be raised.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.AlarmDefinition

## NOTES

## RELATED LINKS
