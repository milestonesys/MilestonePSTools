---
external help file: MilestonePSTools.dll-Help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-LoginSettings/
schema: 2.0.0
---

# Get-LoginSettings

## SYNOPSIS

Gets list of MIP SDK Login Settings for debugging purposes.

## SYNTAX

```
Get-LoginSettings [<CommonParameters>]
```

## DESCRIPTION

The `Get-LoginSettings` cmdlet gets a list of MIP SDK Login Settings of the currently connected system(s).
It is generally used for debugging purposes. The following items are returned:

- Uri
- Guid
- ServerType
- ServerWebType
- Name
- IdentityTokenCache
- NetworkCredential
- CredentialCache
- UriCorporate
- SecureOnly
- Token
- TokenTimeToLive
- UserIdentity
- UserName
- GroupMemberShip
- IsBasicUser
- IsOAuthConnection
- IsOAuthIdentity
- UserInformation
- FullyQualifiedUserName
- InstanceGuid
- ServerProductInfo

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically

## EXAMPLES

### EXAMPLE 1

```powershell
Get-LoginSettings
```

Returns one or more LoginSettings objects - one for each site either connected or available to connect.

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### VideoOS.Platform.Login.LoginSettings

## NOTES

## RELATED LINKS
