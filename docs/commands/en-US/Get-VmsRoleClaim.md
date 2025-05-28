---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Get-VmsRoleClaim/
schema: 2.0.0
---

# Get-VmsRoleClaim

## SYNOPSIS
Gets the claim names and values added to the specified role(s).

## SYNTAX

```
Get-VmsRoleClaim [[-Role] <Role[]>] [[-ClaimName] <String[]>] [-LoginProvider <LoginProvider>]
 [<CommonParameters>]
```

## DESCRIPTION
The `Get-VmsRoleClaim` cmdlet returns claims that have been added to a role. The
claim names and values are used to determine whether an external user should be
granted the privileges associated with the role.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 22.1

## EXAMPLES

### Example 1
```powershell
function Get-VmsRoleClaimReport {
    $providers = Get-VmsLoginProvider
    foreach ($role in Get-VmsRole) {
        foreach ($claim in Get-VmsRoleClaim) {
            [pscustomobject]@{
                Role     = $role.Name
                Provider = ($providers | Where-Object Id -eq $claim.ClaimProvider).Name
                Claim    = $claim.ClaimName
                Value    = $claim.ClaimValue
            }
        }
    }
}
Get-VmsRoleClaimReport | Export-Csv -Path ~\Desktop\Vms-Role-Claim-Report.csv -NoTypeInformation
```

A short function to produce a four-column report in CSV format providing all
claims and values associated with all external login providers, for all roles.
The completed CSV file is saved to the desktop of the current user.

## PARAMETERS

### -ClaimName
Specifies the name(s) of claims to return from the role configuration.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LoginProvider
Only claims associated with the specified external login provider will be returned.
The default is to return claims from all login providers.

```yaml
Type: LoginProvider
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Role
Specifies the role from which to return claims.

```yaml
Type: Role[]
Parameter Sets: (All)
Aliases: RoleName

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### VideoOS.Platform.ConfigurationItems.Role[]

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.ClaimChildItem

## NOTES

## RELATED LINKS
