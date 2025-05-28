---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-UserDefinedEvent/
schema: 2.0.0
---

# Get-UserDefinedEvent

## SYNOPSIS

Gets User-defined Events from the currently connected XProtect VMS site.

## SYNTAX

### ByName (Default)
```
Get-UserDefinedEvent [[-Name] <String>] [<CommonParameters>]
```

### ById
```
Get-UserDefinedEvent [[-Id] <Guid>] [<CommonParameters>]
```

## DESCRIPTION

The `Get-UserDefinedEvent` cmdlet gets User-defined Events from the currently connected VMS site, and
returns them as an object. The output also contains a few 'System' events.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
Get-UserDefinedEvent

<# OUTPUT
Name                   Subtype     LastModified           Id
----                   -------     ------------           --
Force Archive          UserDefined 4/29/2022 1:23:07 PM   FB06ED64-0EA7-4B89-8AED-68FC346BAE42
Gate Event             UserDefined 5/10/2019 7:59:38 AM   FA3645C9-58C1-4E2E-B8A2-3DE7392D7A6D
LockDown               UserDefined 2/24/2021 1:10:02 PM   A8C8C08E-23CF-43EC-B2EA-F4527481E7B3
Panic                  UserDefined 10/18/2017 11:45:50 AM B911C1A3-DED7-4ADF-957C-3038157B2593
RequestPlayAudio       System      10/5/2017 5:17:57 PM   7605F8B0-7F5F-4432-B223-0BB2DC3F1F5C
RequestStartRecording  System      10/5/2017 5:17:40 PM   85867627-B287-4439-9E55-A63701E1715B
RequestStopRecording   System      10/5/2017 5:17:40 PM   77B1E70D-BA8D-4BB8-9EE8-43B09746D82A
Restart                UserDefined 10/17/2023 3:42:44 PM  48FE399C-471F-432F-B702-64D47CF10588
SystemIsDown           UserDefined 2/16/2018 11:13:10 AM  4BAF80FA-ED49-4C58-89AD-1CA8CD68A8EA
#>
```

Returns all User-defined Events in the system, as well as 'System' events.

### Example 2

```powershell
Get-UserDefinedEvent | Where-Object Subtype -eq UserDefined

<# OUTPUT
Name                   Subtype     LastModified           Id
----                   -------     ------------           --
Force Archive          UserDefined 4/29/2022 1:23:07 PM   FB06ED64-0EA7-4B89-8AED-68FC346BAE42
Gate Event             UserDefined 5/10/2019 7:59:38 AM   FA3645C9-58C1-4E2E-B8A2-3DE7392D7A6D
LockDown               UserDefined 2/24/2021 1:10:02 PM   A8C8C08E-23CF-43EC-B2EA-F4527481E7B3
Panic                  UserDefined 10/18/2017 11:45:50 AM B911C1A3-DED7-4ADF-957C-3038157B2593
Restart                UserDefined 10/17/2023 3:42:44 PM  48FE399C-471F-432F-B702-64D47CF10588
SystemIsDown           UserDefined 2/16/2018 11:13:10 AM  4BAF80FA-ED49-4C58-89AD-1CA8CD68A8EA
#>
```

Same as Example 1, except it excludes 'System' events.

### Example 3

```powershell
Get-UserDefinedEvent -Id 'B911C1A3-DED7-4ADF-957C-3038157B2593'

<# OUTPUT
Name  Subtype     LastModified           Id
----  -------     ------------           --
Panic UserDefined 10/18/2017 11:45:50 AM B911C1A3-DED7-4ADF-957C-3038157B2593
#>
```

Returns the User-defined Event with the specified ID.

### Example 4

```powershell
Get-UserDefinedEvent -Name 'Panic' | Send-UserDefinedEvent
```

Get the User-defined Event named 'Panic' and pipes it to `Send-UserDefinedEvent`.

## PARAMETERS

### -Id

Specifies a User-defined Event ID in GUID format.

```yaml
Type: Guid
Parameter Sets: ById
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name

Specifies the name of a User-defined Event.

```yaml
Type: String
Parameter Sets: ByName
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.UserDefinedEvent

## NOTES

## RELATED LINKS
