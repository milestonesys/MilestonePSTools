if ('Restricted' -eq (Get-ExecutionPolicy)) {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Confirm:$false -Force -ErrorAction Stop
}
$ProgressPreference = 'SilentlyContinue'
$requirementsFile = if ($IsLinux) { 'requirements-linux.psd1' } else { 'requirements.psd1' }
Get-PackageProvider -Name Nuget -ForceBootstrap | Out-Null
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

if ($IsLinux) {
    $ProgressPreference = 'SilentlyContinue'
    $requirements = Import-PowerShellDataFile $requirementsFile
    foreach ($key in $requirements.Keys) {
        if ($null -ne $requirements.$key.DependencyType) {
            continue
        }
        if ($key -eq 'PSDependOptions') {
            continue
        }

        $splat = @{
            Name = $key
        }
        if ($requirements.$key.Version) {
            $splat.RequiredVersion = $requirements.$key.Version
        }
        Install-Module @splat -Force -Confirm:$false -Scope CurrentUser
    }
    return
}
if ((Test-Path -Path ./requirements.psd1)) {
    if (-not (Get-Module -Name PSDepend -ListAvailable)) {
        Install-Module -Name PSDepend -Repository PSGallery -Scope CurrentUser -Force
    }
    Import-Module -Name PSDepend -Verbose:$false
    Invoke-PSDepend -Path "$PSScriptRoot/$requirementsFile" -Install -Import -Force -WarningAction SilentlyContinue
} else {
    Write-Warning 'No [requirements.psd1] found. Skipping build dependency installation.'
}
