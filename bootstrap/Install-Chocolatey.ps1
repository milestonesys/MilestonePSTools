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
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ([System.Net.WebClient]::new().DownloadString('https://community.chocolatey.org/install.ps1'))
    $env:ChocolateyInstall = Get-ItemPropertyValue 'hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\' -Name ChocolateyInstall -ErrorAction Stop
    . $Profile
    refreshenv
}

& choco install $PSScriptRoot\choco-packages.config -y --no-progress
