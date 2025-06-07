@{
    RootModule             = 'MilestonePSTools.psm1'
    # Do not change. ModuleVersion is set at build time using nbgv.
    ModuleVersion          = '0.0.1'
    CompatiblePSEditions   = 'Desktop'
    GUID                   = '46909c4a-d5d8-4faf-830d-5a0df564fe7b'
    Author                 = 'Milestone Systems'
    CompanyName            = 'Milestone Systems'
    Copyright              = 'Milestone Systems A/S. All rights reserved.'
    Description            = 'Milestone XProtect VMS configuration and automation powered by Milestone''s MIP SDK.'
    PowerShellVersion      = '5.1'
    DotNetFrameworkVersion = '4.7'
    ProcessorArchitecture  = 'Amd64'
    RequiredModules        = @()
    RequiredAssemblies     = 'System.Drawing', 'System.Device', 'bin/VideoOS.Platform.dll', 'bin/VideoOS.Platform.SDK.dll', 'bin/VideoOS.ConfigurationAPI.dll', 'bin/MilestonePSTools.dll'
    FormatsToProcess       = 'MilestonePSTools.Format.ps1xml'
    FunctionsToExport      = '*'
    CmdletsToExport        = '*'
    AliasesToExport        = '*'
    FileList               = @()
    PrivateData            = @{
        PSData = @{
            Tags         = 'PSEdition_Desktop', 'Windows', 'Milestone', 'ConfigApi',
            'ConfigurationApi', 'XProtect', 'MIPSDK'
            ProjectUri   = 'https://www.milestonepstools.com/'
            IconUri      = 'https://www.milestonepstools.com/assets/images/milestonelogo-85x85.png'
            LicenseUri   = 'https://www.apache.org/licenses/LICENSE-2.0.txt'
            ReleaseNotes = 'See the changelog at https://www.milestonepstools.com/changelog/'
        }
    }
}
