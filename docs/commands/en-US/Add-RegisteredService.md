---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Add-RegisteredService/
schema: 2.0.0
---

# Add-RegisteredService

## SYNOPSIS

Adds a new entry to the list of registered services on the connected Milestone XProtect VMS.

## SYNTAX

```
Add-RegisteredService [-Name] <String> [-Uri] <Uri> [-ServiceType] <Guid> [-Description <String>]
 [-Data <String>] [-InstanceId <Guid>] [<CommonParameters>]
```

## DESCRIPTION

The `Add-RegisteredService` cmdlet adds a new entry to the list of registered services on the connected Milestone XProtect VMS.

The list of registered services are made available to clients so that they may find and connect to additional services. Default
registered service entries typically exist for components like the Event Server, Log Server, Report Server, and Mobile Server(s).

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1

```powershell
$customServiceType = [guid]'327fb419-a331-4a57-9ae5-f848ecf4adf9'
$customServiceInstanceId = [guid]'b8ae97f6-65eb-4b9f-aa76-5b717539c412'
$jsonData = '{}' # (1)!
$optionalData = [convert]::ToBase64String([text.encoding]::UTF8.GetBytes($jsonData))
Add-RegisteredService -Name 'MyCustomService' -Uri https://MyCustomService/ -ServiceType $customServiceType -Description 'My custom service' -Data $optionalData -InstanceId $customServiceInstanceId
```

1. Data can be any string, but a common strategy is to base64 encode a JSON or XML formatted collection of properties to include with the registered service entry.

Creates a new registered service entry with a URI pointing to https://MyCustomService/, a unique custom service type ID, and instance ID, and an empty JSON document converted to Base64 format.

## PARAMETERS

### -Data

Specifies an optional string to include with the registered service entry. This string could be used to store options for a custom developed integration, or parameters for clients to use when communicating with the service for example.

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

### -Description

Specifies an optional descriptive text for the registered service.

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

### -InstanceId

Specifies a unique GUID to reference this _instance_ of the registered service with the provided _ServiceType_.

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

### -Name

Specifies a name for the new registered service entry.

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

### -ServiceType

Specifies an ID representing the type of registered service entry this will be. Built-in Milestone services have their own ServiceType IDs, and each
instance of a service will have a unique InstanceId. A custom service entry will have it's own ServiceType ID that should be the same across every
installation which makes it easy for you to discover _instances_ of services of that specific type.

```yaml
Type: Guid
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri

Specifies a URI to use to reach the registered service.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
