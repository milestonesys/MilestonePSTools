Write-Host 'Setting SecurityProtocol to TLS 1.2 and greater' -ForegroundColor Green
$protocol = [Net.SecurityProtocolType]::SystemDefault
[enum]::GetNames([Net.SecurityProtocolType]) | Where-Object {
    # Match any TLS version greater than 1.1
            ($_ -match 'Tls(\d)(\d+)?') -and ([version]("$($Matches[1]).$([int]$Matches[2])")) -gt 1.1
} | Foreach-Object { $protocol = $protocol -bor [Net.SecurityProtocolType]::$_ }
[Net.ServicePointManager]::SecurityProtocol = $protocol

Write-Host 'Setting Execution Policy to RemoteSigned' -ForegroundColor Green
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Confirm:$false -Force -ErrorAction SilentlyContinue

if ($null -eq (Get-PackageSource -Name NuGet -ErrorAction Ignore)) {
    Write-Host 'Registering NuGet package source' -ForegroundColor Green
    $null = Register-PackageSource -Name NuGet -Location https://www.nuget.org/api/v2 -ProviderName NuGet -Trusted -Force
}

$nugetProvider = Get-PackageProvider -Name NuGet -ErrorAction Ignore
$requiredVersion = [Microsoft.PackageManagement.Internal.Utility.Versions.FourPartVersion]::Parse('2.8.5.201')
if ($null -eq $nugetProvider -or $nugetProvider.Version -lt $requiredVersion) {
    Write-Host 'Installing NuGet package provider' -ForegroundColor Green
    $null = Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
}

if ($null -eq (Get-Module -ListAvailable PowerShellGet | Where-Object Version -ge 2.2.5)) {
    Write-Host 'Installing PowerShellGet 2.2.5 or greater' -ForegroundColor Green
    $null = Install-Module PowerShellGet -MinimumVersion 2.2.5 -Scope CurrentUser -AllowClobber -Force -ErrorAction Stop
}

Write-Host 'Installing MilestonePSTools' -ForegroundColor Green
Install-Module MilestonePSTools -Scope CurrentUser -Force -ErrorAction Stop -SkipPublisherCheck -AllowClobber
