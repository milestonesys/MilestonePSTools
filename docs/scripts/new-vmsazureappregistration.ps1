#Requires -Modules Microsoft.Graph.Applications, Microsoft.Graph.Users, MilestonePSTools, Microsoft.Graph.Authentication, MipSdkRedist
<#
    ## Example use of New-VmsAzureAppRegistration.ps1

    ### Prerequisites

    - Save the script to any location on a computer with network access to your Milestone XProtect VMS as well as
      internet access to reach Azure AD.
    - Ensure the Microsoft.Graph.Applications, Microsoft.Graph.Users, and MilestonePSTools PowerShell modules are
      installed, along with their dependencies: Microsoft.Graph.Authentication and MipSdkRedist.


    The `Install-Module` command may be used to install the required PowerShell modules and their dependencies.

    ```powershell
    Install-Module -Name MilestonePSTools, Microsoft.Graph.Applications, Microsoft.Graph.Users -Scope CurrentUser -Force -Confirm:$false -SkipPublisherCheck -AllowClobber
    ```

    ### Examples

    If your Milestone installation is available at https://myvms.company.domain, the following would configure Azure and
    Milestone.

    ```powershell
    .\New-VmsAzureAppRegistration.ps1 -AppName 'My VMS' -TenantId a12345b6-7cd8-90e1-f234-5678901234ab -InformationAction Continue
    ```

    Including `-Force` will cause a matching Azure App Registration and/or Milestone external login provider to be deleted and recreated.

    ```powershell
    .\New-VmsAzureAppRegistration.ps1 -AppName 'My VMS' -TenantId a12345b6-7cd8-90e1-f234-5678901234ab -InformationAction Continue -Force
    ```

    Including `-Confirm:$false` will prevent interactive confirmation dialogs from being presented to the terminal.

    ```powershell
    .\New-VmsAzureAppRegistration.ps1 -AppName 'My VMS' -TenantId a12345b6-7cd8-90e1-f234-5678901234ab -InformationAction Continue -Force -Confirm:$false
    ```

    ## Manual configuration of Azure AD authentication in Milestone.

    ### Azure AD App Registration:

    - Azure AD > App Registrations > Create new "Web" application with the required redirect uri https://my.vms.address/idp/signin-oidc,
      and one optional redirect uri for each Milestone XProtect Mobile Server, for example: https://my.vms.address:8082/idp/signin-oidc.
    - Under Authentication in the new app registration, ensure "ID tokens (used for implicit and hybrid flows)" is selected.
    - Under Certificates & secrets in the new app registration, create a new secret and save the secret text for later. This will be the
      Client Secret which is paired with the Client Id when adding an external login provider in Milestone.

    ### Milestone External Identity Provider:

    - Ensure you have the following information from the Azure App Registration:
        - TenantId: Find this in the Azure AD App Registration settings under "Overview". It is listed as "Directory (tenant) ID".
        - ClientId: Find this in the Azure AD App Registration settings under "Overview". It is listed as "Application (client) ID".
        - ClientSecret: Generate this in the Azure AD App Registration settings under "Certificates & secrets".
        - Authority URI: This URI is "https://login.microsoftonline.com/$tenantId/v2.0" where `$tenantId` is your Azure AD TenantId.
        - Scopes: When adding an external identity provider in Milestone using the Management Client, the required scopes are
          automatically included. When using MilestonePSTools, you may need to include the default scopes "email", and "profile".
    - Login to Milestone XProtect Management Client.
    - Open Tools > Options > External IDP and add an external IDP.
    - Enter a display name for the login provider and the Client ID, Client secret, and Authentication authority values for Azure AD.
    - Leave callback path at the default value '/signin-oidc'.
    - Optionally uncheck "prompt user for login" if you want to allow users to skip entering Azure AD credentials when they're already logged in.
    - Enter "email" for the claim name to use to create user names.
    - Ensure the "email", and "profile" scopes are included, and click OK.
    - Add at least one registered claim. This can be any claim name you expect to see on user tokens from Azure AD.
      - If you're not sure what claim name to use, consider skipping this step until after the first Azure AD login attempt. At that point
        you can view the claims for that user in Management Client under Security > Basic Users to determine if the required claim(s) are
        present, and if they have the expected values. Then re-visit the external IDP settings and add a registered claim.
    - Add at least one claim/value pair to each role in Milestone that you want Azure AD users to be assigned.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    # Specifies the display name of the Azure App Registration and Service
    # Principal to create.
    [Parameter()]
    [string]
    $AppName = 'Milestone XProtect Single sign-on',

    # Specifies the name that will be displayed to Milestone XProtect VMS users
    # for Azure AD authentication. The default value is 'Azure AD'.
    [Parameter()]
    [string]
    $LoginProviderName = 'Azure AD',

    # Specifies the Azure TenantId on which the Azure App Registration should be
    # created. This ID is used to construct the OpenID Connect Authority URI that
    # Milestone will use to redirect clients for authentication.
    [Parameter(Mandatory)]
    [guid]
    $TenantId,

    # Specifies an file path to a 48x48 or 50x50 pixel image in PNG format with
    # an alpha channel (transparency). The maximum file size is 15KB. If no path
    # is provided, a Milestone logo will be used for the Azure App Registration.
    [Parameter()]
    [string]
    $LogoFilePath,

    # Specifies the date of expiration for the ClientSecret generated for the
    # Azure App Registration. The ClientSecret for the external identity
    # provider in Milestone must be updated on or before this date to maintain
    # support for single sign-on of Azure AD users. The default value is a
    # DateTime value 6 months after the current DateTime.
    [Parameter()]
    [ValidateScript({
            if ($_ -le (Get-Date)) {
                throw "Invalid PasswordExpiry value '$($_.ToString('o'))'. DateTime value must be in the future."
            }
            $true
        })]
    [datetime]
    $PasswordExpiry = (Get-Date).AddMonths(6),

    # Specifies that the Azure AD user should always be required to login, even
    # if they're already logged in to Azure AD.
    [Parameter()]
    [switch]
    $AlwaysRequireLogin,

    # Specifies that the Azure App Registration and Milestone External Login
    # Provider should be removed and re-created if they already exist.
    [Parameter()]
    [switch]
    $Force
)

function Get-AzureContext {
    <#
    .SYNOPSIS
    Returns the Microsoft.Graph context for the specified TenantId.

    .DESCRIPTION
    Returns the Microsoft.Graph context for the specified TenantId and if a
    context with the given TenantId and the required scopes 'User.ReadBasic.All',
    'Application.ReadWrite.All' is not available, the `Connect-MgGraph` cmdlet
    will be called with the TenantId and the required scopes as parameters.

    .PARAMETER TenantId
    Context for the specified TenantId will be returned.

    .EXAMPLE
    Get-AzureContext -TenantId a12345b6-7cd8-90e1-f234-5678901234ab

    Returns the Microsoft.Graph context for the specified TenantId and if a
    context with the given TenantId and the required scopes 'User.ReadBasic.All',
    'Application.ReadWrite.All' is not available, the `Connect-MgGraph` cmdlet
    will be called with the TenantId and the required scopes as parameters.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [guid]
        $TenantId
    )

    process {
        $mgScopes = 'User.ReadBasic.All', 'Application.ReadWrite.All'
        $filterScriptBlock = { $_.TenantId -eq $TenantId -and $mgScopes[0] -in $_.Scopes -and $mgScopes[1] -in $_.Scopes }
        if ($null -eq (Get-MgContext | Where-Object $filterScriptBlock)) {
            $null = Disconnect-MgGraph -ErrorAction SilentlyContinue
            Connect-MgGraph -Scopes $mgScopes -TenantId $TenantId -ErrorAction Stop
        }
        $context = Get-MgContext | Where-Object $filterScriptBlock
        if ($null -eq $context) {
            throw "No context available for TenantId $TenantId with scopes $($mgScopes -join ', ')."
        }
        $context
    }
}

function New-VmsMgApplication {
    <#
    .SYNOPSIS
    Creates a new Azure App Registration and Service Principal for single
    sign-on with a Milestone XProtect VMS installation.

    .DESCRIPTION
    Creates a new Azure App Registration and Service Principal for single
    sign-on with a Milestone XProtect VMS installation and returns a hashtable
    with the relevant application properties.

    .PARAMETER Name
    Specifies the display name of the Azure App Registration and Service
    Principal to create.

    .PARAMETER Description
    Specifies the description of the Azure App Registration and Service
    Principal to create.

    .PARAMETER HomePageUrl
    Specifies the address to use as the home page for the Azure App
    Registration. The default address is the URL of your Milestone Management
    Server's Smart Client installation page.

    .PARAMETER LogoFilePath
    Specifies an file path to a 48x48 or 50x50 pixel image in PNG format with
    an alpha channel (transparency). The maximum file size is 15KB.

    .PARAMETER RedirectUris
    Specifies the redirect uris to register with the Azure App Registration. By
    default, two redirect uris will be included; one for the Milestone XProtect
    Management Server, and one for a Milestone XProtect Mobile Server at the
    same URI with port 8082. For example: https://my.vms.address/idp/signin-oidc,
    and https://my.vms.address:8082/idp/signin-oidc.

    .PARAMETER TenantId
    Specifies the Azure TenantId on which the Azure App Registration should be
    created. This ID is used to construct the OpenID Connect Authority URI that
    Milestone will use to redirect clients for authentication.

    .PARAMETER PasswordExpiry
    Specifies an expiry DateTime value for the client password associated with
    the new Azure App Registration.

    .EXAMPLE
    $appParams = @{
        Name = 'Milestone XProtect Single sign-on'
        TenantId = $TenantId
        PasswordExpiry = (Get-Date).AddMonths(6)
        LogoFilePath = $LogoFilePath
    }
    $app = New-VmsMgApplication @appParams -ErrorAction Stop

    Creates a new Azure App Registration and Service Principal with a new App
    Role named VMS.Administrator. The current Azure AD user is assigned to the
    App Role, which means the user's tokens from Azure AD will include the claim
    'roles' with the value 'VMS.Administrator' which can be added to the
    Administrators role in Milestone so that any Azure user assigned the
    VMS.Administrator role in Azure will be a Milestone Administrator.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([hashtable])]
    param(
        [Parameter()]
        [string]
        $Name = 'Milestone XProtect Single sign-on',

        [Parameter()]
        [string]
        $Description = 'Single sign-on for Milestone XProtect VMS',

        [Parameter()]
        [uri]
        $HomePageUrl,

        [Parameter()]
        $LogoFilePath,

        [Parameter()]
        [uri[]]
        $RedirectUris,

        [Parameter(Mandatory)]
        [guid]
        $TenantId,

        [Parameter()]
        [ValidateScript({
                if ($_ -le (Get-Date)) {
                    throw "Invalid PasswordExpiry value '$($_.ToString('o'))'. DateTime value must be in the future."
                }
                $true
            })]
        [datetime]
        $PasswordExpiry = (Get-Date).AddMonths(6)
    )

    process {
        $baseUri = [uribuilder](Get-VmsSite).FQID.ServerId.Uri
        if (-not $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('HomePageUrl')) {
            $HomePageUrl = '{0}{1}' -f $baseUri.Uri, 'installation/'
        }

        if ($RedirectUris.Count -eq 0) {
            $baseUri.Path = '/idp/signin-oidc'
            $msUri = $baseUri.Uri

            $baseUri.Port = 8082
            $mobileUri = $baseUri.Uri
            $RedirectUris = @($msUri, $mobileUri)
        }

        Write-Information "Creating new Azure App Registration '$Name'"
        if ($PSCmdlet.ShouldProcess("App Registration $Name", "Create")) {
            $newAppParams = @{
                DisplayName = $Name
                Description = $Description
                Web         = @{
                    HomePageUrl           = $HomePageUrl
                    ImplicitGrantSettings = @{
                        EnableIdTokenIssuance = $true
                    }
                    RedirectUris          = $RedirectUris
                }
                AppRoles    = @(@{
                        DisplayName        = 'VMS.Administrator'
                        Value              = 'VMS.Administrator'
                        Description        = 'Milestone XProtect VMS administrators with full access to all resources and settings available in all Milestone applications and APIs.'
                        AllowedMemberTypes = 'User', 'Application'
                        IsEnabled          = $true
                        Id                 = New-Guid
                    })
            }
            $app = New-MgApplication @newAppParams -ErrorAction Stop
            if (-not [string]::IsNullOrWhiteSpace($LogoFilePath) -and (Test-Path -Path $LogoFilePath)) {
                # New-MgApplication has a -LogoInputFile parameter, but it doesn't work currently. See [microsoftgraph/msgraph-sdk-powershell issue #935](https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/935#issuecomment-1072897650)
                Write-Information "Uploading app logo"
                Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/beta/applications/$($app.Id)/logo" -Method PUT -InputFilePath $LogoFilePath -ContentType 'image/png'
            }
    
            Write-Information "Creating service principal for AppId $($app.AppId)"
            $servicePrincipal = New-MgServicePrincipal -AppId $app.AppId -Description $Description -ErrorAction Stop
    
            $currentAADUser = Get-MgUser
    
            Write-Information "Assigning VMS.Administrator role to user '$($currentAADUser.DisplayName)'"
            $appRoleAssignmentParams = @{
                AppRoleId   = $newAppParams.AppRoles[0].Id
                UserId      = $currentAADUser.Id
                PrincipalId = $currentAADUser.Id
                ResourceId  = $servicePrincipal.Id
            }
            $null = New-MgUserAppRoleAssignment @appRoleAssignmentParams
    
            Write-Information "Generating application password for ClientSecret"
            $appPasswordParams = @{
                ApplicationId      = $app.Id
                PasswordCredential = @{
                    DisplayName = 'Created from PowerShell'
                    EndDateTime = $PasswordExpiry
                }
            }
            $secret = Add-MgApplicationPassword @appPasswordParams -ErrorAction Stop
    
            Write-Information "Azure application successfully created."
            @{
                Application  = $app
                ClientId     = $app.AppId
                ClientSecret = $secret.SecretText | ConvertTo-SecureString -AsPlainText -Force
                Authority    = 'https://login.microsoftonline.com/{0}/v2.0' -f $TenantId
            }
        }
    }
}

function Save-MilestoneLogoFile {
    <#
    .SYNOPSIS
    Saves a 50x50 pixel Milestone logo to a file in PNG format.

    .DESCRIPTION
    Saves a 50x50 pixel Milestone logo to a file in PNG format.

    .PARAMETER Path
    Specifies the path to save the logo in PNG format. If no path is provided, a random temp file will be used.

    .EXAMPLE
    $logoFilePath = Save-MilestoneLogoFile

    Generates a Milestone logo in a temp file and returns the path.

    .EXAMPLE
    Save-MilestoneLogoFile -Path .\logo.png

    Saves a Milestone logo in PNG format to a file named "logo.png" in the current folder.
    #>
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $Path = [io.path]::GetTempFileName()
    )

    begin {
        $Path = ((Resolve-Path -Path $Path -ErrorAction SilentlyContinue -ErrorVariable rpe).Path)
        if ($rpe) {
            $Path = $rpe.TargetObject
        }
    }

    process {
        # 50x50 pixel PNG of the blue diamond Milestone Systems logo.
        $pngBytes = [convert]::FromBase64String('iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsEAAA7BAbiRa+0AAAGVSURBVGhD3dg7UsMwFIVhJ4tha3SUMKSBNBBKymwtq0HH8gE8tmU9zpXl/DOyLHXf+FGoM+96+3Lje1iZdRxmm663d3d9duPJ3V/6PaPsIB7x5hd9L8OeSYdh1jZF/O/cPT7IQXpIGMHkGC0kDsGkGB0kDcFkGA0kD8EkmHJIGYIVY8ogGgQrwuRDtAiWjcmD2CBYFiYdYotgyZg0SB0ES8LEQ+oiWDQmDrINgkVh1iHbItgqJgxpA8GCmGVIWwi2iJmHtIlgs5gppG0Em2DGkH0g2AjzB9kXgv1iPGSfCNZjDg7x4Ravfm+3fdqea1Xs6B7Lyc1nv9xleLVOd/axs7v4/bJ9YEYINIWgtjETBJqHoDYxswi0DEFtYRYRKAxBbWCCCLQOQdtiVhEoDoK2wUQhUDwE1cVEI1AaBNXBJCFQOgTZYpIRKA+CbDBZCJQPQVpMNgKVQZAGU4RA5RBUhilGIA0E5WEkCKSDoDSMDIG0EBSHkSKQHoLCGDkC2UDQPMYEgewgaIwxQ9QJB4D+ENCwrvsBOTTD3sVPCC0AAAAASUVORK5CYII=')
        [io.file]::WriteAllBytes($Path, $pngBytes)
        $Path
    }
}

if ($null -eq (Get-VmsManagementServer -ErrorAction SilentlyContinue)) {
    Connect-Vms -ShowDialog -AcceptEula
}
Write-Information "Connected to Milestone XProtect site '$((Get-VmsManagementServer).Name)'"

if (($loginProvider = Get-VmsLoginProvider)) {
    if ($Force) {
        Write-Warning "Removing existing external identity provider in Milestone XProtect VMS site '$((Get-VmsSite).Name)'"
        $loginProvider | Remove-VmsLoginProvider -Force -Confirm:($ConfirmPreference -ge 'High') -WhatIf:$WhatIfPreference
    } else {
        throw "External login provider already configured on Milestone XProtect VMS: $($loginProvider.Name). Remove the existing login provider and try again, or re-run this script with the -Force parameter."
    }
}

$context = Get-AzureContext -TenantId $TenantId
$TenantId = $context.TenantId
Write-Information "Connected to Azure AD tenant $TenantId with account $($context.Account)."

if ($PSCmdlet.ShouldProcess("Azure AD Tenant $TenantId", "Create Azure App Registration '$AppName'")) {
    $existingApp = Get-MgApplication -Filter "DisplayName eq '$AppName'"
    if ($existingApp) {
        if ($Force) {
            $existingApp | ForEach-Object {
                Write-Warning "Removing existing Azure AD App Registration matching DisplayName '$AppName'"
                $null = Remove-MgApplication -ApplicationId $_.Id -ErrorAction Stop -Confirm:($ConfirmPreference -ge 'High') -WhatIf:$WhatIfPreference
            }
        } else {
            throw "Azure App Registration '$AppName' already exists on TenantId $TenantId. Remove the App Registration, use a new name, or re-run this script with the -Force parameter."
        }
    }
    if ([string]::IsNullOrWhiteSpace($LogoFilePath)) {
        $LogoFilePath = Save-MilestoneLogoFile
    }
    $appParams = @{
        Name           = $AppName
        TenantId       = $TenantId
        PasswordExpiry = $PasswordExpiry
        LogoFilePath   = $LogoFilePath
    }
    $app = New-VmsMgApplication @appParams -ErrorAction Stop
}

if ($PSCmdlet.ShouldProcess((Get-VmsSite).Name, 'Configure Azure AD as the external login provider')) {
    $loginProviderParams = @{
        Name          = $LoginProviderName
        ClientId      = $app.ClientId
        ClientSecret  = $app.ClientSecret
        CallbackPath  = '/signin-oidc'
        Authority     = $app.Authority
        UserNameClaim = 'email'
        Scopes        = 'email', 'profile'
        PromptForLogin = $AlwaysRequireLogin
    }

    Write-Information "Adding external login provider to Milestone XProtect VMS"
    $loginProvider = New-VmsLoginProvider @loginProviderParams -ErrorAction Stop

    Write-Information "Adding 'roles' as registered claim 'Role' for new login provider on Milestone XProtect VMS"
    $loginProvider | Add-VmsLoginProviderClaim -Name 'roles' -DisplayName 'Role' -ErrorAction Stop

    Write-Information "Adding claim/value pair 'roles: VMS.Administrator' to Administrators role on Milestone XProtect VMS."
    Get-VmsRole -RoleType Adminstrative | Add-VmsRoleClaim -LoginProvider $loginProvider -ClaimName 'roles' -ClaimValue 'VMS.Administrator' -ErrorAction Stop

    Write-Information "Azure AD App Registration and Milestone Login Provider setup completed."
    Write-Information "You may now login to Milestone as a member of the Administrators role using your current Azure AD account."
}
