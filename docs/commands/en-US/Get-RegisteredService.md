---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-RegisteredService/
schema: 2.0.0
---

# Get-RegisteredService

## SYNOPSIS

Gets a list of matching registered service records.

## SYNTAX

```
Get-RegisteredService [-ServiceType <Guid>] [-Name <String>] [<CommonParameters>]
```

## DESCRIPTION

The `Get-RegisteredService` cmdlet gets a list of matching registered service records. Registered services are records
available in Management Client under Tools > Registered Services. These records are used by clients, and/or integrations
to discover the availability and addresses of optional VMS services like the Event Server, Log Server, Mobile Servers,
or 3rd party integrations with their own service addresses.

| Default Service          | ServiceType                          |  
| -------------------------|--------------------------------------|  
| Log server               | 3d6f1153-92ad-43f1-b467-9482ffd291b2 |  
| Legacy log server        | 002b1b2f-0817-4592-8c62-2fe5107c160c |  
| Event Server service     | 08ab8f23-9aef-4298-9caa-f39259fe7cda |  
| Incident Manager service | 3ce6b5e2-d861-4c0b-9085-00b938b2f45a |  
| Report Server            | a9f27a6a-9488-44e3-ac0b-0cb1c86ccd2a |  
| Management Server        | a10cd823-bb4e-4d31-a162-dd236fc78fa6 |  
  
REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
$incidentManagerUri = (Get-RegisteredService -ServiceType 3ce6b5e2-d861-4c0b-9085-00b938b2f45a).UriArray[0]
$incidentManagerUri
```

Gets the URL for the incident manager service. For example `http://management1/IncidentManager/`.

## PARAMETERS

### -Name

Specifies the name of the registered service entry to return, with support for wildcards.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceType

Specifies the type of registered service entry (or entries) to return. Each registered service has a ServiceType `[guid]`
which may not be unique, and an InstanceId `[guid]` which must be unique within the Milestone XProtect VMS site.

```yaml
Type: Guid
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

### None

## OUTPUTS

### VideoOS.Platform.Configuration+ServiceURIInfo

## NOTES

## RELATED LINKS
