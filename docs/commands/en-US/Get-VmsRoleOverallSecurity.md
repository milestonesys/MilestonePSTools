---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsRoleOverallSecurity/
schema: 2.0.0
---

# Get-VmsRoleOverallSecurity

## SYNOPSIS
Gets the overall security settings per security namespace for a role.

## SYNTAX

```
Get-VmsRoleOverallSecurity [-Role] <Role> [[-SecurityNamespace] <Guid[]>] [<CommonParameters>]
```

## DESCRIPTION
Gets the overall security settings per security namespace for a role. With the
exception of the default Administrators role, roles have a collection of
"Overall Security" namespaces, each with their own set of permissions.

A security namespace defines a group of related permissions such as "Cameras" or
"Management Server". The "Cameras" security namespace defines permissions like
"VIEW_LIVE" or "PLAYBACK". The values of all permissions in overall security are
either "Allow", "Deny" or "None" with the default value of "None".

Permissions in Milestone are cumulative, with a "Deny" taking priority over any
"Allow". For example, if you are a member of Role A and Role B, with Role A
giving you permission to export video, but Role B has a "Deny" for the same
security attribute, then you will not be allowed to export video.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### Example 1
```powershell
Get-VmsRoleOverallSecurity -Role 'Operators' -SecurityNamespace Alarms
```

Gets the overall security settings for Alarms, for the role named "Operators".

### Example 2
```powershell
$role = Get-VmsRole -Name 'Operators'
$role | Get-VmsRoleOverallSecurity -SecurityNamespace '623d03f8-c5d5-46bc-a2f4-4c03562d4f85'
```

Gets the overall security settings for the Cameras security namespace using the unique ID of that security namespace which can reduce the time to resolve namespaces. This can help reduce the time it takes to retrieve/update overall security settings on systems with 1000+ roles.

## PARAMETERS

### -Role
Specifies the role object, or the name of the role.

```yaml
Type: Role
Parameter Sets: (All)
Aliases: RoleName

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -SecurityNamespace
Specifies the name or ID of an existing security namespace.

```yaml
Type: Guid[]
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

### VideoOS.Platform.ConfigurationItems.Role

## OUTPUTS

### System.Collections.Hashtable
## NOTES

## RELATED LINKS
