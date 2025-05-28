---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsConnectionString/
schema: 2.0.0
---

# Get-VmsConnectionString

## SYNOPSIS

Gets the Management Server's SQL connection string from the registry.

## SYNTAX

```
Get-VmsConnectionString [[-Component] <String>] [<CommonParameters>]
```

## DESCRIPTION

The Get-VmsConnectionString cmdlet gets the connection string value from either
HKLM:\SOFTWARE\VideoOS\Server\Common, or on versions 2022 R3 and later,
HKLM:\SOFTWARE\VideoOS\Server\ConnectionString.

IMPORTANT: It is not recommended, or supported, to manipulate data in the SQL
database(s) used by Milestone XProtect products. The database schema is not
documented, and may change without warning between product versions.

However, it is occasionally useful to read or modify database contents. If you
choose to do so, it is at your own risk. Please be sure to create a configuration
backup from Management Client, or a SQL database backup, before making any
changes.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VmsConnectionString
```

Gets the current ManagementServer connection string value from the registry.

### EXAMPLE 2

```powershell
Get-VmsConnectionString LogServer
```

Gets the current LogServer connection string value from the registry, but only
on VMS versions 2022 R3 and later.

## PARAMETERS

### -Component
Specifies the name of the connection string value to retrieve from the registry.
On VMS versions 2022 R3 and later, these may include EventServer, IDP,
IncidentManager, LogServer, ManagementServer, ReportServer, and ServerService.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: ManagementServer
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS
