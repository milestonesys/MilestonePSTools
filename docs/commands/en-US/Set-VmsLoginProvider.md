---
external help file: MilestonePSTools-help.xml
Module Name: MilestonePSTools
online version: https://www.milestonepstools.com/commands/en-US/Set-VmsLoginProvider/
schema: 2.0.0
---

# Set-VmsLoginProvider

## SYNOPSIS
Sets the specified properties of an existing external login provider.

## SYNTAX

```
Set-VmsLoginProvider [-LoginProvider] <LoginProvider> [[-Name] <String>] [[-ClientId] <String>]
 [[-ClientSecret] <SecureString>] [[-CallbackPath] <String>] [[-Authority] <Uri>] [[-UserNameClaim] <String>]
 [[-Scopes] <String[]>] [[-PromptForLogin] <Boolean>] [[-Enabled] <Boolean>] [-PassThru] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
The `Set-VmsLoginProvider` cmdlet is used to update the settings of an existing
external login provider.

REQUIREMENTS  

- Requires VMS connection and will attempt to connect automatically
- Requires VMS version 22.1

## EXAMPLES

### Example 1
```powershell
Set-VmsLoginProvider -LoginProvider Auth0 -ClientSecret (Read-Host -Prompt 'Secret' -AsSecureString) -Verbose
```

If a login provider named 'Auth0' is present, the secret will be requested, and
then updated in the VMS configuration.

## PARAMETERS

### -Authority
Specifies the URI for the external login provider to which VMS users will be
redirected for authentication.

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
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
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientId
Specifies the client id value unique to the external login provider.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Enabled
Specifies whether the external login provider should be enabled immediately.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LoginProvider
Specifies the login provider to be updated. If the name is provided, the
login provider object will be retrieved automatically.

```yaml
Type: LoginProvider
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
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

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Specifies that the updated login provider object should be returned to the pipeline.

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

### -PromptForLogin
Specify to the external IDP if the user should stay logged in or if a
verification of the user is required. Depending on the external IDP, the
verification can include a password verification or a full log-in.

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
Position: 7
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
Position: 6
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

### VideoOS.Platform.ConfigurationItems.LoginProvider

## OUTPUTS

### VideoOS.Platform.ConfigurationItems.LoginProvider

## NOTES

## RELATED LINKS
