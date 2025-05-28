---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Remove-UserDefinedEvent/
schema: 2.0.0
---

# Remove-UserDefinedEvent

## SYNOPSIS

Removes a User-defined Event from the system.

## SYNTAX

### ByName (Default)
```
Remove-UserDefinedEvent [-Name] <String> [<CommonParameters>]
```

### FromPipeline
```
Remove-UserDefinedEvent [-UserDefinedEvent] <UserDefinedEvent> [<CommonParameters>]
```

### ById
```
Remove-UserDefinedEvent [-Id] <Guid> [<CommonParameters>]
```

## DESCRIPTION

The `Remove-UserDefinedEvent` cmdlet removes a specified User-defined Event from the system. It can remove
using the User-defined Event object or simply using the Name or ID.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Remove-UserDefinedEvent -Name 'SampleUDE'
```

Removes the User-defined Event with the name 'SampleUDE'

### Example 2

```powershell
Get-UserDefinedEvent -Id '0EFBD109-1F88-4E58-947D-8EDE63412E49' | Remove-UserDefinedEvent
```

Gets a User-defined Event with ID '0EFBD109-1F88-4E58-947D-8EDE63412E49' and pipes it to Remove-UserDefinedEvent to remove it.

## PARAMETERS

### -Id

Specifies the ID of the User-defined Event object to be deleted.

```yaml
Type: Guid
Parameter Sets: ById
Aliases:

Required: True
Position: 3
Default value: 00000000-0000-0000-0000-000000000000
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Specifies the Name of the User-defined Event object to be deleted.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserDefinedEvent

Specifies a User-defined Event to be removed, as returned by `Get-UserDefinedEvent`.

```yaml
Type: UserDefinedEvent
Parameter Sets: FromPipeline
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.UserDefinedEvent

## OUTPUTS

## NOTES

## RELATED LINKS
