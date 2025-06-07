Properties {
    $Configuration = 'Release'

    $usings = @'
using namespace System.Collections.Generic
using namespace System.Management.Automation
using namespace System.Text.RegularExpressions
using namespace System.Windows.Forms
using namespace MilestonePSTools
using namespace MilestonePSTools.Utility
using namespace VideoOS.Platform.ConfigurationItems
'@
    $functions = Join-Path $psake.build_script_dir 'build.functions.ps1'
    . $functions
    $PSBPreference.General.ModuleVersion = (dotnet nbgv get-version -f json | ConvertFrom-Json).SimpleVersion
    $PSBPreference.Build.CompileModule = $true
    $PSBPreference.Build.CompileHeader = "$usings`r`nImport-Module `"`$PSScriptRoot\bin\MilestonePSTools.dll`""
    $PSBPreference.Build.CopyDirectories = 'bin', 'en-US'
    $PSBPreference.Help.DefaultLocale = 'en-US'
    $PSBPreference.Docs.RootDir = './docs/commands'
    $PSBPreference.Docs.AlphabeticParamsOrder = $true
    $PSBPreference.Docs.ExcludeDontShow = $true
    $PSBPreference.Test.OutputFile = 'out/testResults.xml'
    $PSBPreference.Test.SkipRemainingOnFailure = 'Run'
    $PSBPreference.Test.OutputVerbosity = 'Normal'
    $PSBPreference.Test.ScriptAnalysis.SettingsPath = Join-Path $psake.build_script_dir 'tests\ScriptAnalyzerSettings.psd1'

    $psake.context.tasks.stagefiles.PostAction = {
        # Update the module version in the module manifest
        $outputManifestPath = [io.path]::Combine($PSBPreference.Build.ModuleOutDir, "$($PSBPreference.General.ModuleName).psd1")
        Update-Metadata -Path $outputManifestPath -PropertyName ModuleVersion -Value $PSBPreference.General.ModuleVersion

        # Remove all the copies of license headers from the original ps1 files in "compiled" psm1 file
        $outputPsm1Path = [io.path]::Combine($PSBPreference.Build.ModuleOutDir, "$($PSBPreference.General.ModuleName).psm1")
        $licenseHeader = @'
# Copyright 2025 Milestone Systems A/S
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
'@ -split "\r?\n"
        $stringBuilder = [text.stringbuilder]::new()
        $licenseHeader | ForEach-Object {
            $null = $stringBuilder.AppendLine($_)
        }
        
        try {
            $stream = [io.file]::OpenRead($outputPsm1Path)
            $reader = [io.streamreader]::new($stream)
            do {
                $line = $reader.ReadLine()
                if ($line -match '^#') {
                    $isLicenseHeader = $false
                    foreach ($headerLine in $licenseHeader) {
                        if ($line -match "^$([regex]::Escape($headerLine))`$") {
                            $isLicenseHeader = $true
                            break
                        }
                    }
                    if ($isLicenseHeader) {
                        continue
                    }
                }
                $null = $stringBuilder.AppendLine($line)
            } while ($null -ne $line)
        } finally {
            $reader.Dispose()
        }
        [io.file]::WriteAllText($outputPsm1Path, $stringBuilder.ToString(), [text.encoding]::UTF8)
    }

    $psake.context.tasks.GenerateMAML.DependsOn += @('SetOnlineHelpUrls', 'AddCommandRequirementsToDocs')
    $psake.context.tasks.Build.DependsOn += @(,'RestoreDependencyModules')

    # if ($SkipHelp -or -not (Test-DocsRebuildRequired)) {
    #     Write-Host 'Skipping task "GenerateMarkdown" since the markdown hasn''t changed' -ForegroundColor Magenta
    #     $psake.context.tasks.buildhelp.DependsOn = $psake.context.tasks.buildhelp.DependsOn | Where-Object { $_ -ne 'GenerateMarkdown' }
    #     $psake.context.tasks.GenerateMAML.DependsOn = $psake.context.tasks.GenerateMAML.DependsOn | Where-Object { $_ -ne 'GenerateMarkdown' }
    # }

    $script:EmbeddedModules = @(
        @{
            Name            = 'ImportExcel'
            RequiredVersion = '7.8.9'
        }
    )
}

Task Default -depends StageCmdletLib, Build, UpdateModuleExports, ExportCommandHistory, generate-compatibility-table

Task Build -FromModule PowerShellBuild -minimumVersion '0.7.2'

Task Test -FromModule PowerShellBuild -minimumVersion '0.7.2'

Task RunTests -depends Default, Test -description 'Build the project and execute tests.'

Task -name CacheDependencyModules {
    $cachePath = Join-Path $psake.build_script_dir '.cache\modules'
    $null = New-Item -Path $cachePath -ItemType Directory -Force
    foreach ($module in $script:EmbeddedModules) {
        $moduleFolder = Join-Path $cachePath $module.Name
        $moduleVersionFolder = Join-Path $moduleFolder $module.RequiredVersion
        $hashPath = Join-Path $moduleVersionFolder 'checksum.csv'
        
        # Validate cache if present
        $cacheIsValid = $true
        if (Test-Path $hashPath) {
            $checksums = Import-Csv -Path $hashPath
            $files = Get-ChildItem -Path $moduleVersionFolder -File -Recurse | Where-Object Name -ne 'checksum.csv'
            if ($checksums.Count -ne $files.Count) {
                $cacheIsValid = $false
            }

            if ($cacheIsValid) {
                foreach ($checksum in $checksums) {
                    $filePath = Join-Path $moduleVersionFolder $checksum.Path
                    $fileHash = Get-FileHash -Path $filePath -Algorithm $checksum.Algorithm
                    if ($fileHash.Hash -ne $checksum.Hash) {
                        Write-Warning "Cached file '$($filePath)' has been modified. Rebuilding module cache for $($module.Name) v$($module.RequiredVersion)"
                        $cacheIsValid = $false
                        break
                    }
                }
            }
        } else {
            $cacheIsValid = $false
        }

        if ($cacheIsValid) {
            continue
        }

        if (Test-Path $moduleFolder) {
            Remove-Item -Path $moduleFolder -Recurse -Force
        }
        
        Write-Host "Caching module $($module.Name) v$($module.RequiredVersion)" -ForegroundColor Green
        Save-Module -Name $module.Name -RequiredVersion $module.RequiredVersion -Path $cachePath
        
        $moduleFiles = Get-ChildItem -Path $moduleVersionFolder -File -Recurse
        $moduleFiles | Get-FileHash -Algorithm SHA256 | ForEach-Object {
            $_.Path = $_.Path -replace [regex]::Escape($moduleVersionFolder)
            $_.Path = $_.Path -replace '^[\\/]'
            $_
        } | Export-Csv -Path $hashPath
    }
}

Task -name RestoreDependencyModules -depends CacheDependencyModules {
    $cachePath = Join-Path $psake.build_script_dir '.cache\modules'
    $embeddedModulesPath = New-Item -Path (Join-Path $PSBPreference.Build.ModuleOutDir modules) -ItemType Directory -Force
    if (Test-Path $embeddedModulesPath) {
        Remove-Item -Path $embeddedModulesPath -Recurse -Force -ErrorAction Stop
    }
    foreach ($module in $script:EmbeddedModules) {
        $srcModuleFolder = Join-Path $cachePath $module.Name
        $srcModuleVersionFolder = Join-Path $srcModuleFolder $module.RequiredVersion
        $dstModuleFolder = Join-Path $embeddedModulesPath $module.Name
        $dstModuleVersionFolder = Join-Path $dstModuleFolder $module.RequiredVersion
        $null = New-Item -Path $dstModuleVersionFolder -ItemType Directory -Force
        Get-ChildItem -Path $srcModuleVersionFolder | Copy-Item -Destination $dstModuleVersionFolder -Recurse
    }
}

Task -name CreateOrUpdateChecksumFile {
    Get-FolderChecksum -Path $psake.build_script_dir -Recurse -Algorithm SHA256 | ForEach-Object {
        $_.ToString()
    } | Set-Content -Path (Join-Path $psake.build_script_dir '.checksums')
}

Task -name ExportCommandHistory -depends Build {
    $functions = Join-Path $psake.build_script_dir 'build.functions.ps1'
    . $functions
    $outputManifestPath = [io.path]::Combine($PSBPreference.Build.ModuleOutDir, "$($PSBPreference.General.ModuleName).psd1")
    Import-Module $outputManifestPath -Force
    
    $jsonPath = Join-Path -Path $PSBPreference.Docs.RootDir -ChildPath 'command-history.json'
    $history = Get-Module -name MilestonePSTools | Get-CommandHistory
    
    $updateCommandHistory = $true
    if (Test-Path -Path $jsonPath) {
        $existingCommands = (Get-Content -Path $jsonPath | ConvertFrom-Json).Commands | ConvertTo-Json
        $updatedCommands = ($history | ConvertTo-Json | ConvertFrom-Json).Commands | ConvertTo-Json
        if ($existingCommands -ceq $updatedCommands) {
            $updateCommandHistory = $false
        }
    }
    if ($updateCommandHistory) {
        $history | ConvertTo-Json | Set-Content -Path $jsonPath
    } else {
        Write-Host "No changes made to affect command-history.json." -ForegroundColor Magenta
    }

    $mdTablePath = Join-Path -Path $PSBPreference.Docs.RootDir -ChildPath 'commands.mdtable'
    if ($updateCommandHistory -or -not (Test-Path $mdTablePath)) {
        $commands = $history.Commands | Where-Object { $null -eq $_.DateRemoved } | Sort-Object Name
        $columns = @(
            @{
                Name       = 'Command'
                Expression = {
                    '[{0}]({0}.md)' -f $_.Name
                }
            },
    
            @{
                Name       = 'From version'
                Expression = {
                    $version = $_.VersionAdded
                    '[{0}]({1}){{:target="_blank"}}' -f $version, "https://www.powershellgallery.com/packages/$($_.Module)/$version"
                }
            },
    
            @{
                Name       = 'Date Published'
                Expression = {
                    $_.DatePublished.ToString('yyyy-MM-dd')
                }
            },
    
            @{
                Name       = 'Aliases'
                Expression = {
                    $command = $_
                    ($_.Aliases | ForEach-Object { '[{0}]({1}.md)' -f $_, $command.Name }) -join ' '
                }
            }
        )
        
        $commands | Select-Object $columns | ConvertTo-MarkdownTable | Set-Content -Path $mdTablePath
    } else {
        Write-Host "No changes made to affect commands.mdtable." -ForegroundColor Magenta
    }
}

Task -name SetOnlineHelpUrls {
    foreach ($locale in Get-ChildItem -Path 'docs\commands' -Directory) {
        foreach ($md in $locale.GetFiles('*.md')) {
            $name = $md.BaseName
            $lang = $locale.BaseName
            $dirty = $false
            $lines = Get-Content -Path $md.FullName -Encoding UTF8 | ForEach-Object {
                if ($_ -match '^online version:.*$') {
                    $newLine = "online version: https://www.milestonepstools.com/commands/$lang/$name/"
                    $newLine
                    $dirty = $dirty -or $_ -cne $newLine
                } else {
                    $_
                }
            }
            if ($dirty) {
                Write-Host "Adding/updating URL for online version of help for $name`: $(Resolve-Path -Path $md.FullName -Relative)"
                $lines | Set-Content -Path $md.FullName -Encoding UTF8
            }
        }
    }
}

Task -name AddCommandRequirementsToDocs {
    $moduleDir = $PSBPreference.Build.ModuleOutDir
    $functions = Join-Path $psake.build_script_dir 'build.functions.ps1'
    $workingDirectory = $psake.build_script_dir
    Start-Job -ArgumentList $moduleDir, $functions, $workingDirectory {
        param([string]$moduleDir, [string]$functions, [string]$workingDirectory)

        [Environment]::CurrentDirectory = $workingDirectory
        Push-Location $workingDirectory

        Import-Module (Join-Path $moduleDir 'MilestonePSTools.psd1')
        Add-Type -Path (Join-Path $moduleDir 'bin\MilestonePSTools.dll')
        . $functions
        Update-VmsDocs
    } | Receive-Job -Wait -AutoRemoveJob
}

Task -name UpdateModuleExports {
    $manifestPath = [io.path]::combine($env:BHBuildOutput, "$($env:BHProjectName).psd1")
    $cmdletsJob = Start-Job -ScriptBlock {
        param($modulePath)
        Import-Module $modulePath
        Get-Command -Module MilestonePSTools -CommandType Cmdlet | Select-Object -ExpandProperty Name
    } -ArgumentList $manifestPath
    $aliasesJob = Start-Job -ScriptBlock {
        param($modulePath)
        Import-Module $modulePath
        Get-Command -Module MilestonePSTools -CommandType Alias | Select-Object -ExpandProperty Name
    } -ArgumentList $manifestPath
    $cmdlets = $cmdletsJob | Receive-Job -Wait -AutoRemoveJob
    $aliases = $aliasesJob | Receive-Job -Wait -AutoRemoveJob
    Update-Metadata -Path $manifestPath -PropertyName CmdletsToExport -Value $cmdlets
    Update-Metadata -Path $manifestPath -PropertyName AliasesToExport -Value $aliases
}

Task -name CleanOutput -depends Init -action {
    if (Test-Path $PSBPreference.Build.OutDir) {
        Get-ChildItem $PSBPreference.Build.OutDir | Remove-Item -Recurse
    }
}

Task -name CheckMsBuild -description 'Verify MSBuild version in PATH is >= 16.0' -action {
    $msbuildVersion = [version](msbuild /version)[-1]
    Assert ($msbuildVersion -ge '16.0') -failureMessage "Expected MSBUILD v16+ but found $msbuildVersion"
}

Task -name CheckVersion -description 'Verify the version in version.json matches the MIP SDK nuget package version' {
    $csprojPath = Join-Path $psake.build_script_dir 'src\MilestonePSTools\MilestonePSTools.csproj'
    $jsonPath = Join-Path $psake.build_script_dir 'version.json'
    $xml = [xml]([io.file]::ReadAllText($csprojPath))
    $node = $xml.Project.ItemGroup.PackageReference | Where-Object Include -EQ 'MilestoneSystems.VideoOS.Platform.SDK'
    $mipVersion = [version]$node.Version
    $gitversion = [version]([io.file]::ReadAllText($jsonPath) | ConvertFrom-Json).Version
    Assert ($mipVersion.ToString(2) -eq $gitversion.ToString(2)) -failureMessage "Version of 'MilestoneSystems.VideoOS.Platform.SDK' nuget package and version in version.json do not match."
}

Task -name CompileLib -depends CheckMsBuild, CheckVersion, CleanOutput -description 'Compile the MilestonePSTools C# Library' -action {
    foreach ($csproj in Get-ChildItem -Path (Join-Path $psake.build_script_dir '\src\*.csproj') -Recurse) {
        Exec {
            $outputPath = Join-Path $PSBPreference.Build.OutDir "/lib/$($csproj.BaseName)"
            msbuild "$($csproj.FullName)" "/p:Configuration=$Configuration;Platform=x64;OutputPath=$outputPath" /v:quiet -restore
        }
    }
}

Task -name ClearModuleBinaries -description 'Remove old copies of MilestonePSTools DLLs from Module bin folder' -action {
    $path = Join-Path $PSBPreference.General.SrcRootDir 'bin'
    if (Test-Path $path) {
        Get-ChildItem -Path $path | Remove-Item -Recurse
    } else {
        $null = New-Item -Path $path -ItemType Directory
    }
}

Task -name StageCmdletLib -depends CompileLib, ClearModuleBinaries -description 'Copy compiled MilestonePSTools library into the module source folder' -action {
    $sdkSrc = Join-Path $PSBPreference.Build.OutDir '\lib\MilestonePSTools'
    $sdkDst = Join-Path $PSBPreference.General.SrcRootDir 'Bin'
    $null = New-Item -Path $sdkDst -ItemType Directory -Force

    Get-ChildItem -Path $sdkSrc | Copy-Item -Destination $sdkDst -Recurse

    # Fixes issue #126 https://github.com/MilestoneSystemsInc/PowerShellSamples/issues/126
    $h265_sw_lib = Join-Path $sdkDst '15dd936825ad475ea34e35f3f54217a6\mfxplugin64_hevcd_sw.dll'
    if (Test-Path $h265_sw_lib) {
        $dst = Join-Path $sdkDst 'mfxplugin64_sw.dll'
        Copy-Item -Path $h265_sw_lib -Destination $dst
    }
}

Task -name SignWithAzureSignTool {
    $modulePath = Join-Path $psake.build_script_dir 'Output\MilestonePSTools\'
    $extensions = @('.ps1xml', '.psd1', '.psm1', '.ps1', '.dll')
    $fileList = Join-Path $psake.build_script_dir 'files-to-sign.txt'
    $files = Get-ChildItem -Path $modulePath -File -Recurse | Where-Object Extension -In $extensions | Select-Object -ExpandProperty FullName
    $files | Set-Content -Path $fileList
    
    Exec {
        $signingArgs = @(
            # --description-url
            '-du',  'https://www.milestonepstools.com',
            # --azure-key-vault-managed-identity
            '-kvm',
            # --azure-key-vault-url
            '-kvu', $env:AZUREKEYVAULT_URI,
            # --azure-key-vault-certificate
            '-kvc', $env:AZUREKEYVAULT_CERTNAME,
            # --input-file-list
            '-ifl', $fileList,
            # --timestamp-rfc3161
            '-tr', 'http://timestamp.digicert.com',
            # --verbose
            '-v'
        )
        & dotnet azuresigntool sign $signingArgs
    }
}

Task -name PublishModule {
    $modulePath = Join-Path $psake.build_script_dir 'Output\MilestonePSTools\'
    Publish-Module -Path $modulePath -NuGetApiKey (${env:NUGETAPIKEY}) -Verbose
}

Task -name pull-mkdocs-material-insiders {
    Assert (-not [string]::IsNullOrWhiteSpace($env:GHCR_TOKEN)) -failureMessage 'The GHCR_TOKEN environment variable must be set to pull the latest mkdocs-material-insiders image from ghcr.io.'
    ${env:GHCR_TOKEN} | docker login -u joshooaj --password-stdin ghcr.io
    docker pull ghcr.io/milestonesystemsinc/mkdocs-material-insiders:latest
}

Task -name generate-compatibility-table {
    $mdTablePath = Join-Path $psake.build_script_dir 'docs\compatibility.mdtable'
    Get-SupportedVmsTable -NotBefore (Get-Date).AddYears(-6) | Sort-Object Vms -Descending | ForEach-Object {
        [pscustomobject]@{
            'XProtect VMS Version'     = 'XProtect {0}' -f $_.Vms
            'Latest Compatible Module' = '[MilestonePSTools {0}]({1})' -f $_.Module.Version, $_.Module.Uri
            'Date Published'           = $_.Module.PublishedDate.ToString('yyyy-MM-dd')
            'Supported[^1]'                = if ($_.Published -ge (Get-Date).AddYears(-3)) { 'Yes' } else { 'No' }
        }
    } | ConvertTo-MarkdownTable | Set-Content -Path $mdTablePath
}

Task -name PublishDocs -depends pull-mkdocs-material-insiders, generate-compatibility-table {
    # Add block override to overrides\main.html (https://squidfunk.github.io/mkdocs-material/customization/#overriding-blocks)
    $mainPath = Join-Path $psake.build_script_dir 'docs\overrides\main.html'

    # Add meta http-equiv tags to improve security due to GitHub Pages not
    # allowing users to set their own HTTP headers. This is being added at
    # build time only when publishing to GitHub Pages because if these tags are
    # present when doing local development, a number of things break when using
    # mkdocs serve.
    $extrahead = @'
{% block extrahead %}
    <meta http-equiv="Content-Security-Policy" content="default-src 'unsafe-inline' 'unsafe-eval' data: https://*">
    <meta http-equiv="Content-Security-Policy-Report-Only" content="default-src 'unsafe-inline' 'unsafe-eval' data: https://*; report-uri https://milestonepstools.report-uri.com/r/d/csp/reportOnly">

    <meta http-equiv="Cross-Origin-Resource-Policy" content="same-origin">

    <meta http-equiv="Permissions-Policy" content="clipboard-write=(self)">
    <meta http-equiv="Referrer-Policy" content="strict-origin-when-cross-origin">

    <meta http-equiv="Strict-Transport-Security" content="Strict-Transport-Security: max-age=31536000; includeSubDomains">

    <meta http-equiv="X-Content-Type-Options" content="nosniff">
    <meta http-equiv="X-Frame-Options" content="SAMEORIGIN">
{% endblock %}
'@
    if ($env:BHBuildSystem -eq 'GitHub Actions') {
        Write-Verbose 'Appending extrahead override block to docs/overrides/main.html'
        $extrahead | Add-Content -Path $mainPath
    } else {
        Write-Verbose "extrahead override block not added for build system '$($env:BHBuildSystem)'"
    }

    Exec {
        docker run -v "$($psake.build_script_dir)`:/docs" -e 'CI=true' --entrypoint 'sh' ghcr.io/milestonesystemsinc/mkdocs-material-insiders:latest -c 'apk add --no-cache pngquant py3-cffi musl-dev pango && pip install -r requirements.txt && mkdocs gh-deploy --force'
    }
}

Task -name mkdocs-build -depends pull-mkdocs-material-insiders, generate-compatibility-table -action {
    $outputPath = [io.path]::combine($psake.build_script_dir, 'Output')
    $null = New-Item -Path $outputPath -ItemType Directory -Force
    Exec {
        docker run -v "$($psake.build_script_dir)`:/docs" --entrypoint 'sh' ghcr.io/milestonesystemsinc/mkdocs-material-insiders:latest -c 'apk add --no-cache pngquant py3-cffi musl-dev pango && pip install -r requirements.txt && mkdocs build'
    }
}

Task -name mkdocs-serve -depends pull-mkdocs-material-insiders, generate-compatibility-table -description 'Serve mkdocs site locally' {
    $null = docker pull -q ghcr.io/milestonesystemsinc/mkdocs-material-insiders:latest 2>&1
    if ($LASTEXITCODE -ne 0) {
        $pat = ${env:GHCR_TOKEN}
        if ([string]::IsNullOrWhiteSpace($pat)) {
            $securePat = Read-Host -Prompt 'Please enter a personal access token to pull the mkdocs-material-insiders image' -AsSecureString
            $pat = [pscredential]::new('a', $securePat).GetNetworkCredential().Password
        }
        $pat | docker login -u joshooaj --password-stdin ghcr.io
        $output = docker pull ghcr.io/milestonesystemsinc/mkdocs-material-insiders:latest 2>&1
        if (!$?) {
            throw $output.Exception.Message
        }
        $output
    }
    docker run --rm -it -p 8000:8000 -v "$($psake.build_script_dir)`:/docs" --entrypoint 'sh' ghcr.io/milestonesystemsinc/mkdocs-material-insiders:latest -c 'apk add --no-cache pngquant py3-cffi musl-dev pango && pip install -r requirements.txt && mkdocs serve --dev-addr=0.0.0.0:8000'
}

Task -name integration-tests -description 'Run integration tests from the tests/MilestonePSTools folder' {
    $outputModVerManifest = Join-Path -Path $env:BHBuildOutput -ChildPath "$($env:BHProjectName).psd1"
    
    $integrationTestEntrypoint = Join-Path $psake.build_script_dir 'tests/MilestonePSTools/MilestonePSTools.integration.tests.ps1'
    $testConfig = New-PesterConfiguration -Hashtable @{
        Run = @{
            Container = New-PesterContainer -Path $integrationTestEntrypoint -Data @{
                ModulePath = $outputModVerManifest
            }
            SkipRemainingOnFailure = 'Container'
            Throw = $true
        }
        Output = @{
            Verbosity = 'Detailed'
        }
    }
    Invoke-Pester -Configuration $testConfig
}
