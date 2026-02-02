---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-ItemState/
schema: 2.0.0
---

# Get-ItemState

## SYNOPSIS

Gets the ItemState of all known items in the site

## SYNTAX

```
Get-ItemState [-CamerasOnly] [[-Timeout] <TimeSpan>] [<CommonParameters>]
```

## DESCRIPTION

The `Get-ItemState` cmdlet sends a "MessageCommunication.ProvideCurrentStateRequest" message and returns the response
from the XProtect Event Server.

The `VideoOS.Platform.Messaging.ItemState` objects returned by this command have an `FQID` and `State` property, and
using the `FQID` this command enriches the output by adding the item `Name`, `ItemType`, and `Id` as note properties.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-ItemState -CamerasOnly | Where-Object State -ne "Responding" | Foreach-Object { $camera = Get-VmsCamera -Id $_.FQID.ObjectId; Write-Warning "Camera $($camera.Name) state is $($_.State)" }
```

Write a warning for every camera found with a state that is not "Responding"

### EXAMPLE 2

```powershell
Get-ItemState | ForEach-Object { Get-VmsCamera -Id $_.FQID.ObjectId | Get-ConfigurationItem -ParentItem }
```

Gets the associated Hardware object for every Camera ItemState result.

## PARAMETERS

### -CamerasOnly

Filter the ItemState results to Camera items

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

### -Timeout
Specifies a timeout period in the form of a TimeSpan. The default value is 60 seconds.

```yaml
Type: TimeSpan
Parameter Sets: (All)
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

## OUTPUTS

### VideoOS.Platform.Messaging.ItemState

## NOTES

## RELATED LINKS
