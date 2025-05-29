$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

$cachedModulePath = Resolve-Path $PSScriptRoot/../.cache/modules
$requirementsFile = if ($IsLinux) { Join-Path $PSScriptRoot requirements-linux.psd1 } else { Join-Path $PSScriptRoot requirements.psd1 }
$requirements = Import-PowerShellDataFile $requirementsFile
foreach ($kvp in $requirements.GetEnumerator()) {
    if (!$kvp.Value.ContainsKey('Name')) {
        $kvp.Value.Name = $kvp.Key.ToString()
    }
    if (!$kvp.Value.ContainsKey('DependencyType')) {
        $kvp.Value.DependencyType = 'PSGalleryModule'
    }
}
$completedScripts = @{}
    
$moduleJobs = $requirements.Values | Where-Object { $_.DependencyType -eq 'PSGalleryModule' } | ForEach-Object {
    Start-Job -Name "Install $($_.Name)" -ScriptBlock {
        param($moduleName, $requiredVersion, $path, $psmodulepath)
        $ErrorActionPreference = 'Stop'
        $ProgressPreference = 'SilentlyContinue'
        $env:PSModulePath = $psmodulepath
        if ($null -eq (Get-Module -Name $moduleName -ListAvailable | Where-Object Version -EQ $requiredVersion)) {
            Save-Module -Name $moduleName -Path $path -RequiredVersion $requiredVersion -Force -Confirm:$false
        }
        $moduleName
    } -ArgumentList $_.Name, $_.Version, $cachedModulePath, $env:PSModulePath
}
$moduleJobs | Receive-Job -Wait -AutoRemoveJob | ForEach-Object {
    Write-Host "Module saved to $cachedModulePath`: $_" -ForegroundColor Cyan
    $completedScripts[$_] = $null
}

$scripts = [collections.generic.queue[object]]::new()
$requirements.Values | Where-Object { $_.DependencyType -eq 'task' } | ForEach-Object {
    $scripts.Enqueue($_)
}
$maxIterations = [math]::Pow($scripts.Count, 2)
$iterations = 0
while ($scripts.Count -gt 0) {
    $iterations++
    if ($iterations -gt $maxIterations) {
        throw "Circular dependency detected in bootstrap scripts. Please check $requirementsFile"
    }

    $script = $scripts.Dequeue()
    if ($script.ContainsKey('DependsOn') -and !$completedScripts.ContainsKey($script.DependsOn)) {
        $scripts.Enqueue($script)
        continue
    }
    try {
        Write-Host "Bootstrapping $($script.Name). . ." -ForegroundColor Cyan
        & (Join-Path $PSScriptRoot $script.Target)
        if (!$?) {
            throw "Failed to execute bootstrap script '$($script.Target)'"
        }
        $completedScripts[$script.Name] = $null
    } catch {
        throw
    }
}
