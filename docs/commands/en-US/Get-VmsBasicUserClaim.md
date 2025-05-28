---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsBasicUserClaim/
schema: 2.0.0
---

# Get-VmsBasicUserClaim

## SYNOPSIS
Gets the claims associated with an external user's login provider.

## SYNTAX

```
Get-VmsBasicUserClaim [-InputObject] <BasicUser[]> [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsBasicUserClaim` cmdlet applies only to basic users where the
"IsExternal" property is `$true`. When an external user authenticates with the
VMS, a collection of claims and their values are included in the token issued
by the external login provider. These claims can be inspected using this cmdlet.

| ClaimName      | ClaimValue                         |
| -------------- | ---------------------------------- |
| email          | username@domain.ext                |
| email_verified | True                               |
| name           | username@domain.ext                |
| nickname       | username                           |
| picture        | https://s.gravatar.com/avatar/.... |
| vms_roles      | Administrators                     |

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 22.1

## EXAMPLES

### Example 1
```powershell
Get-VmsBasicUser -Name 'username@domain.ext' | Get-VmsBasicUserClaim | Select-Object ClaimName, ClaimValue
```

Gets the claim names and values associated with the basic user with name 'username@domain.ext'.

## PARAMETERS

### -InputObject
Specifies one or more basic user objects returned by `Get-VmsBasicUser`.

```yaml
Type: BasicUser[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.BasicUser[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ClaimChildItem

## NOTES

## RELATED LINKS
