---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-WhoIsOnline/
schema: 2.0.0
---

# Get-WhoIsOnline

## SYNOPSIS

Gets the response to the MIP message 'MessageCommunication.WhoAreOnlineRequest'

## SYNTAX

```
Get-WhoIsOnline [[-Timeout] <Double>] [<CommonParameters>]
```

## DESCRIPTION

The MIP SDK provides the MessageCommunication.WhoAreOnlineRequest and MessageCommunication.WhoAreOnlineResponse messages for getting a list of endpoint FQID's which can then potentially be used as destination addresses for other MIP messages.
Each EndPointIdentityData object provides an 'IdentityName' property with the format 'Administrator (0.0.0.0)' which can be used to get a general idea of who is connected to the Management Server and from which network location.
Note that this is not meant as a perfect user session monitoring solution and you may see duplicate entries including entries representing the Milestone services themselves such as for the Event Server or Log Server.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-WhoIsOnline
```

Get a list of user sessions with a default timeout value of 10 seconds

### EXAMPLE 2

```powershell
Get-WhoIsOnline -Timeout 2
```

Get a list of user sessions with a custom timeout value of 2 seconds

## PARAMETERS

### -Timeout

Time, in seconds, to wait for the first result.

```yaml
Type: Double
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.Messaging.EndPointIdentityData

## NOTES

## RELATED LINKS
