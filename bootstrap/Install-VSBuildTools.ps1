if ($null -eq (Get-VSSetupInstance | Where-Object InstallationVersion -ge '17.0')) {
    try {
        $ProgressPreference = 'SilentlyContinue'
        Push-Location $HOME\Downloads
        [Environment]::CurrentDirectory = $PWD.Path
        Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release.ltsc.17.4/vs_buildtools.exe' -OutFile '.\vs_buildtools.exe'
        Start-Process vs_buildtools.exe -ArgumentList "--quiet", "--wait", "--norestart", "--nocache", "--add Microsoft.VisualStudio.Workload.ManagedDesktop", "--add Microsoft.Net.Component.4.7.2.SDK" -Wait
        if ($null -eq (Get-VSSetupInstance | Where-Object InstallationVersion -ge '17.0')) {
            throw "Failed to install and discover Visual Studio build tools version 17+"
        }
        Remove-Item -Path 'vs_buildtools.exe'
        Invoke-WebRequest -Uri 'https://download.visualstudio.microsoft.com/download/pr/158dce74-251c-4af3-b8cc-4608621341c8/9c1e178a11f55478e2112714a3897c1a/ndp472-devpack-enu.exe' -UseBasicParsing -OutFile '.\ndp472-devpack-enu.exe'
        Start-Process ndp472-devpack-enu.exe -ArgumentList "/q", "/norestart" -Wait
        Remove-Item -Path 'ndp472-devpack-enu.exe'
    } finally {
        Pop-Location
        [Environment]::CurrentDirectory = $PWD.Path
    }
}
