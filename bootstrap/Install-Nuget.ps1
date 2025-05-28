if ($null -eq (Get-Command nuget -ErrorAction Ignore)) {
    choco install nuget.commandline -y --no-progress
    refreshenv
    nuget sources add -name NuGet -Source https://www.nuget.org/api/v2
}
