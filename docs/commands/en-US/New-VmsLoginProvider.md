---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/New-VmsLoginProvider/
schema: 2.0.0
---

# New-VmsLoginProvider

## SYNOPSIS
Adds a new external login provider to enable authentication by an external identity provider.

## SYNTAX

```
New-VmsLoginProvider [-Name] <String> [-ClientId] <String> [-ClientSecret] <SecureString>
 [[-CallbackPath] <String>] [-Authority] <Uri> [[-UserNameClaim] <String>] [[-Scopes] <String[]>]
 [[-PromptForLogin] <Boolean>] [[-Enabled] <Boolean>] [<CommonParameters>]
```

## DESCRIPTION
The `New-VmsLoginProvider` cmdlet adds a new external login provider to enable
authentication by an external identity provider. This functionality was introduced
to the XProtect VMS in version 2022 R1, and enables authentication to be managed
not only by Windows, Active Directory, or Milestone "basic users", but by an
external identity provider with support for OpenID Connect or OIDC.

Note: Only identity providers with support for OpenID Connect are supported with
this feature. Future versions of the XProtect VMS may introduce support for
additional protocols such as SAML.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 22.1

## EXAMPLES

### Example 1
```powershell
if (Get-VmsLoginProvider) {
    throw "Existing login provider found. To run this example, please remove the existing login provider using 'Get-VmsLoginProvider | Remove-VmsLoginProvider -Force'."
}

# While this script has been tested and confirmed to work at the time of writing,
# the clientid, clientsecret, and authority below are fictional values.
$providerParams = @{
    Name          = 'Auth0'
    ClientId      = 'qgrWLy9ho81mKErhK7ZD4k82rLXKLGgB'
    ClientSecret  = 'M_4P4IZQo0X4oxPwrrxWkh8y8Hjas9yl8VOFM6DQR4jlvMdJB3S0oL768b25MtIA' | ConvertTo-SecureString -AsPlainText -Force
    Authority     = 'https://dev-hYz2AYg0WmmTSE4C.us.auth0.com'
    UserNameClaim = 'email'
    Scopes        = 'email', 'profile'
    Verbose       = $true
    ErrorAction   = 'Stop'
}
# Adds the external login provider
$loginProvider = New-VmsLoginProvider @providerParams

# Registers a claim so that a claim name/value can later be added to a role
$loginProvider | Add-VmsLoginProviderClaim -Name 'vms_role' -Verbose

# Adds the "vms_role" claim to all roles, with a value matching the name of the role.
# Any user from the external login provider with the "vms_role" claim will now be a member of the matching role.
Get-VmsRole | Foreach-Object { $_ | Add-VmsRoleClaim -LoginProvider $loginProvider -ClaimName 'vms_role' -ClaimValue $_.Name -Verbose }
```

This example script performs all the necessary configuration to add a new external
identity provider (IDP). In the case of this example, it is expected that users
will have a claim in their token named "vms_role", and the value of that claim
will match the name of a role in the VMS.

Note that the ClientId, ClientSecret, and Authority are always unique to every
production identity provider. And identity provider will also likely have a
unique set of scopes, and claims, so you should not expect this example to work
as-is, unless you have confirmed with the administrator for your identity management
system that users will have a claim named "vms_role", and that the value of this
claim will match the name of a role in the VMS.

## PARAMETERS

### -Authority
Specifies the URI for the external login provider to which VMS users will be
redirected for authentication.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CallbackPath
Specifies the path to which users will be redirected after completing the
login process with the external login provider. The CallbackPath value represents
the portion of the management server URI that comes after the dns name and port.
The default value is '/signin-oidc' and the value is not normally changed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: /signin-oidc
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientId
Specifies the client id value unique to the external login provider.

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

### -ClientSecret
Specifies the client secret value unique to the external login provider.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Enabled
Specifies whether the external login provider should be enabled immediately. The
default value is `$true`.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Specifies the display name for the external login provider. This value will be
displayed in the list of authentication options in supported clients including
Smart Client, Web Client, Mobile Client, and Management Client.

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

### -PromptForLogin

Specify to the external IDP if the user should stay logged in or if a
verification of the user is required. Depending on the external IDP, the
verification can include a password verification or a full log-in.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scopes

Use scopes to limit the number of claims that you get from an external IDP.
If you know that the claims that are relevant for your VMS are in a specific
scope, you can use the scope to limit the number of claims that you get from
the external IDP.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserNameClaim
Specifies the claim name to use to generate a unique user name for the user in
the VMS. See the [Unique user names for external IDP users](https://doc.milestonesys.com/latest/en-US/standard_features/sf_mc/sf_systemoverview/mc_external_idpexplained.htm#Unique_user_names_for_external_IDP_users_) documentation for more
information about how user names are created within the VMS.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LoginProvider

## NOTES

## RELATED LINKS
