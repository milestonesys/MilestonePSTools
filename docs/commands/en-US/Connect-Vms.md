---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Connect-Vms/
schema: 2.0.0
---

# Connect-Vms

## SYNOPSIS
Connects to a Milestone XProtect Management Server.

## SYNTAX

### ConnectionProfile (Default)
```
Connect-Vms [-Name <String>] [-IncludeChildSites] [-AcceptEula] [-NoProfile] [<CommonParameters>]
```

### ShowDialog
```
Connect-Vms [-Name <String>] [-ShowDialog] [-IncludeChildSites] [-AcceptEula] [<CommonParameters>]
```

### ServerAddress
```
Connect-Vms [-Name <String>] -ServerAddress <Uri> [-Credential <PSCredential>] [-BasicUser] [-SecureOnly]
 [-IncludeChildSites] [-AcceptEula] [<CommonParameters>]
```

## DESCRIPTION
The `Connect-Vms` cmdlet connects to a Milestone XProtect Management Server. When used on a parent management server in
a Milestone Federated Hierarchy, the -IncludeChildSites parameter can be used to login to child sites as well.

**Important:** It is required to include `-AcceptEula` once. After this, an empty file is saved to the current user's roaming Windows
profile at `#!powershell $env:APPDATA\MilestonePSTools\user-accepted-eula.txt` to indicate that Milestone's MIP SDK end user
license agreement has been accepted and the `-AcceptEula` switch will not be required again unless MilestonePSTools is used
on another computer or another Windows user account.

REQUIREMENTS  

- Does not require a VMS connection

## EXAMPLES

### Example 1
```powershell
Connect-Vms -AcceptEula
```

If a Milestone connection profile named "default" already exists, a connection will be established to the management server
address in that connection profile. If no such profile exists, a Milestone login dialog will be displayed. The "-AcceptEula"
parameter is only required the first time the command is used by the current Windows user. If the command is used later
under a different Windows user account, the "-AcceptEula" parameter will be required one time for that user.

### Example 2
```powershell
Connect-Vms -Name 'MyVMS'
```

If a Milestone connection profile named "MyVMS" already exists, a connection will be established to the management server
address in that connection profile. If no such profile exists, a Milestone login dialog will be displayed. Upon successful
logon, the named profile will be saved to disk, and calling `Connect-Vms -Name MyVMS` in the future will automatically
connect to the same server address with the same credentials.

### Example 3
```powershell
Connect-Vms -ServerAddress 'http://MyVMS' -Credential (Get-Credential)
```

Prompt for a Windows or Active Directory credential, and then establish a connection to http://MyVMS.

### Example 4
```powershell
Connect-Vms -Name 'MyVMS' -ServerAddress 'http://MyVMS' -Credential (Get-Credential)
```

Prompt for a Windows or Active Directory credential, and then establish a connection to http://MyVMS. Upon successful
connection, a connection profile named "MyVMS" will be added or updated.

### Example 5
```powershell
Connect-Vms -ShowDialog
```

Show a Milestone login dialog.

### Example 6
```powershell
Connect-Vms -Name 'MyVMS' -ShowDialog
```

Show a Milestone login dialog, and on successful connection, add or update the connection profile named "MyVMS".

## PARAMETERS

### -AcceptEula
Indicates that you accept the terms of the end user license agreement supplied with the MilestonePSTools module, which
is a copy of the agreement supplied with Milestone's SDK. You can review the EULA at any time using `Invoke-MipSdkEula`.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -BasicUser
Specifies that the provided Credential should be interpreted as a Milestone Basic User credential instead of a Windows
or Active Directory credential.

```yaml
Type: SwitchParameter
Parameter Sets: ServerAddress
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Credential
Specifies the username and password for a Windows, Active Directory, or Milestone Basic User. When using basic user
credentials, you must also use the "-BasicUser" switch.

```yaml
Type: PSCredential
Parameter Sets: ServerAddress
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -IncludeChildSites
Specifies that a logon session should also be established with all Milestone Federated Hierarchy (MFA) child sites, if present.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Name
Specifies the name of the connection profile, with a default value of "default". When used alone, or when calling
Connect-Vms without parameters, the server address and encrypted credential will be loaded from disk and a connection
will be established without providing any additional information. If no connection profile exists matching the provided,
or default name, a Milestone login dialog will be displayed. Upon successful logon, a named connection profile will be
saved to the current user's local AppData folder.

When the Name parameter is provided with the ShowDialog or ServerAddress parameter sets, a named connection profile will
be saved to disk after successful connection. If a connection profile with that name already exists, it will be updated.

```yaml
Type: String
Parameter Sets: ConnectionProfile
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ShowDialog, ServerAddress
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -NoProfile
Specifies that no connection profile should be created after successful login. This is used when automatic login is
desired, and a login dialog should be presented if the named profile does not exist, but no _new_ named profile should
be created. When the `[RequiresVmsConnection()]` attribute calls `Connect-Vms`, it uses this parameter so that automatic
logon is possible without implicitly saving a new connection profile.

```yaml
Type: SwitchParameter
Parameter Sets: ConnectionProfile
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SecureOnly
Specifies that a secure connection is required. If a secure connection cannot be established, this parameter ensures that
an insecure HTTP connection should not be attempted.

```yaml
Type: SwitchParameter
Parameter Sets: ServerAddress
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ServerAddress
Specifies the Management Server address using either an http or https scheme. For example, "http://managementserver".

```yaml
Type: Uri
Parameter Sets: ServerAddress
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ShowDialog
Specifies that a Milestone login dialog should be displayed. This should only be used when using MilestonePSTools
interactively.

REQUIREMENTS  

- Requires an interactive PowerShell session.

```yaml
Type: SwitchParameter
Parameter Sets: ShowDialog
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Values from pipeline by property name

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ManagementServer

## NOTES

## RELATED LINKS
