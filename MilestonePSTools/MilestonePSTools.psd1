@{
    RootModule             = 'MilestonePSTools.psm1'
    # Do not change. ModuleVersion is set at build time using nbgv.
    ModuleVersion          = '0.0.1'
    CompatiblePSEditions   = 'Desktop'
    GUID                   = '46909c4a-d5d8-4faf-830d-5a0df564fe7b'
    Author                 = 'Joshua Hendricks'
    CompanyName            = 'Milestone Systems, Inc.'
    Copyright              = '(c) 2019-2023 Milestone Systems. All rights reserved.'
    Description            = 'Milestone XProtect VMS configuration and automation powered by the Milestone MIP SDK.'
    PowerShellVersion      = '5.1'
    DotNetFrameworkVersion = '4.7'
    ProcessorArchitecture  = 'Amd64'
    RequiredModules        = @()
    RequiredAssemblies     = 'System.Drawing', 'System.Device', 'bin/VideoOS.Platform.dll', 'bin/VideoOS.Platform.SDK.dll', 'bin/VideoOS.ConfigurationAPI.dll', 'bin/MilestonePSTools.dll'
    FormatsToProcess       = 'MilestonePSTools.Format.ps1xml'
    FunctionsToExport      = '*'
    CmdletsToExport        = '*'
    AliasesToExport        = '*'
    FileList               = @('assets/MIPSDK_EULA.txt')
    PrivateData            = @{
        PSData = @{
            Tags         = 'PSEdition_Desktop', 'Windows', 'Milestone', 'ConfigApi',
            'ConfigurationApi', 'XProtect', 'MIPSDK'
            ProjectUri   = 'https://www.milestonepstools.com/'
            IconUri      = 'https://www.milestonepstools.com/assets/images/milestonelogo.png'
            ReleaseNotes = 'See the changelog at https://www.milestonepstools.com/changelog/'
        }
    }
}
