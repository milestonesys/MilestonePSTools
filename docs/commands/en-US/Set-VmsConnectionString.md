---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsConnectionString/
schema: 2.0.0
---

# Set-VmsConnectionString

## SYNOPSIS
Sets the SQL connection string for the specified VMS component.

## SYNTAX

```
Set-VmsConnectionString [-Component] <String> [-ConnectionString] <String> [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The Set-VmsConnectionString cmdlet sets the connection string value for the
specified VMS component. The connection strings are stored in the registry key
HKLM:\SOFTWARE\VideoOS\Server\ConnectionString.

If there is no existing registry value matching the specified component name,
one can be created by including the -Force switch. Under normal circumstances it
should never be necessary to create new registry values in this way, but if, for
some reason, a registry key is removed or missing, it can be recreated this way.

After changing a SQL connection string, it will be necessary to restart the
related Windows Service(s) and IIS application pools where applicable.

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

### Example 1
```powershell
Set-VmsConnectionString -Component ManagementServer -ConnectionString "Data Source=sql01;Initial Catalog=Surveillance;Integrated Security=True;Max Pool Size=1000;Encrypt=True;TrustServerCertificate=True"
```

Sets the ManagementServer SQL connection string to use the SQL server "sql01".
Under normal circumstances, all databases used by the VMS are on the same SQL
server and some components should use the same connection string since they
use some of the same database tables.

## PARAMETERS

### -Component
Specifies the name of an existing connection string value, or a new connection
string value to be created. Existing values include include EventServer, IDP,
IncidentManager, LogServer, ManagementServer, ReportServer, and ServerService.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConnectionString
A Microsoft SQL connection string.

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

### -Force
Specifies that the connection string value should be created if it doesn't exist.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

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

### None

## NOTES

## RELATED LINKS
