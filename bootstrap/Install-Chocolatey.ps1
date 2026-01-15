if ($null -eq (Get-Command choco -ErrorAction Ignore)) {
    if (-not (Test-Path $Profile)) {
        New-Item -Path $Profile -ItemType File
    }

    # If choco is installed and just not available in $Path yet, get the helper module loaded and invoke refreshenv
    if (Get-ItemProperty 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name ChocolateyInstall -ErrorAction Ignore) {
        $env:ChocolateyInstall = Get-ItemPropertyValue 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name ChocolateyInstall -ErrorAction Stop
        . $Profile
        refreshenv
        if (Get-Command choco -ErrorAction Ignore) {
            return
        }
    }
    $ProgressPreference = 'SilentlyContinue'
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ([System.Net.WebClient]::new().DownloadString('https://community.chocolatey.org/install.ps1'))
    $env:ChocolateyInstall = Get-ItemPropertyValue 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name ChocolateyInstall -ErrorAction Stop
    . $Profile
    refreshenv
}

& choco install "$PSScriptRoot\choco-packages$(if ($env:CI) { '-ci' }).config" -y --no-progress
$env:PATH = "C:\Program Files\dotnet;" + $env:PATH

if ((dotnet nuget list source) -eq 'No sources found.') {
    dotnet nuget add source -n 'nuget.org' 'https://api.nuget.org/v3/index.json'
}
& dotnet tool restore