---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Invoke-Method/
schema: 2.0.0
---

# Invoke-Method

## SYNOPSIS

Invokes a method or command on a given ConfigurationItem

## SYNTAX

```
Invoke-Method -ConfigurationItem <ConfigurationItem> [-MethodId] <String> [<CommonParameters>]
```

## DESCRIPTION

Some ConfigurationItem objects have MethodIds defining commands that can be invoked.
The response to an Invoke-Method command may be a ConfigurationItem of type 'InvokeInfo' which may have one or more properties that need to be filled out before sending the updated InvokeInfo item to the Invoke-Method command again.
Alternatively, if no additional information or Invoke-Method call is needed, the result may be of type InvokeResult.

The result may also be a Task, indicating the operation may take some time.
You can then poll periodically for task status until the State property is 'Completed'.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ConfigurationItem -Path /UserDefinedEventFolder | Invoke-Method -MethodId AddUserDefinedEvent
```

Invokes the AddUserDefinedEvent method which returns a ConfigurationItem of type InvokeInfo.
Fill out the Name property of this ConfigurationItem and resend to the Invoke-Method command to create a new User Defined Event.

## PARAMETERS

### -ConfigurationItem

Specifies the source ConfigurationItem on which the given MethodId will be invoked

```yaml
Type: ConfigurationItem
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -MethodId

Specifies the MethodId string to invoke on the ConfigurationItem

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.ConfigurationApi.ClientService.ConfigurationItem

Specifies the source ConfigurationItem on which the given MethodId will be invoked

## OUTPUTS

### VideoOS.ConfigurationApi.ClientService.ConfigurationItem

## NOTES

## RELATED LINKS

[MIP SDK Configuration API docs](https://doc.developer.milestonesys.com/html/index.html?base=gettingstarted/intro_configurationapi.html&tree=tree_4.html)

