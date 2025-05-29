[cmdletbinding(DefaultParameterSetName = 'Task')]
param(
    # Build task(s) to execute
    [parameter(ParameterSetName = 'task', position = 0)]
    [string[]]$Task = 'default',

    # Bootstrap dependencies
    [switch]$Bootstrap,

    # List available build tasks
    [parameter(ParameterSetName = 'Help')]
    [switch]$Help,

    # Optional properties to pass to psake
    [hashtable]$Properties = @{},

    # Optional parameters to pass to psake
    [hashtable]$Parameters = @{},

    [Parameter(ParameterSetName = 'task')]
    [switch]$SkipIsolation,

    [Parameter(ParameterSetName = 'task')]
    [switch]$SkipHelp
)

if ($Help) {
    Get-PSakeScriptTasks -buildFile $psakeFile  | Format-Table -Property Name, Description, Alias, DependsOn
} elseif (-not $SkipIsolation) {
    $arguments = @(
        ('-Task "{0}"' -f ($Task -join '", "')),
        '-SkipIsolation',
        '-SkipHelp:${0}' -f $SkipHelp.ToBool()
    )
    if ($Bootstrap) {
        $arguments += '-Bootstrap'
    }
    if ($VerbosePreference -eq 'Continue') {
        $arguments += '-Verbose'
    }
    if ($Properties) {
        $arguments += '-Properties'
        $arguments += '@{{{0}}}' -f (($Properties.Keys | Foreach-Object {
            "'{0}' = '{1}'" -f $_, $Properties[$_]
        }) -join '; ')
    }
    if ($Parameters) {
        $arguments += '-Parameters'
        $arguments += '@{{{0}}}' -f (($Parameters.Keys | Foreach-Object {
            "'{0}' = '{1}'" -f $_, $Parameters[$_]
        }) -join '; ')
    }
    $commandArgs = $arguments -join ' '
    $command = "& '{1}' {2}" -f $PSScriptRoot, $PSCommandPath, $commandArgs
    Write-Verbose "Current PID = $PID. Build.ps1 will now be executed in an isolated process."
    Write-Verbose "Executing '$command'"
    & powershell.exe -NoProfile -NoLogo -Command $command
} else {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'

    Write-Verbose "Current PID = $PID"
    $previousPWD = $PWD
    Push-Location $PSScriptRoot
    [Environment]::CurrentDirectory = $PSScriptRoot
    try {
        $cachedModulePath = (New-Item "$PSScriptRoot/.cache/modules/" -ItemType Directory -Force).FullName
        if ($env:PSModulePath -notmatch [regex]::Escape($cachedModulePath)) {
            $env:PSModulePath = $cachedModulePath + [io.path]::PathSeparator + $env:PSModulePath
        }

        # Bootstrap dependencies
        if ($Bootstrap) {
            . $PSScriptRoot\bootstrap\bootstrap.ps1
        }

        # Execute psake task(s)
        $psakeFile = "$PSScriptRoot/psakefile.ps1"
        if ($PSCmdlet.ParameterSetName -eq 'Help') {
            Get-PSakeScriptTasks -buildFile $psakeFile |
            Format-Table -Property Name, Description, Alias, DependsOn
        } else {
            Set-BuildEnvironment -Force
            $Parameters.SkipHelp = $SkipHelp.ToBool()
            $env:VMS_ApplicationInsights__Enabled = $false
            if ($Task -contains 'SignModule') {
                Invoke-psake -buildFile $psakeFile -taskList SignModule -nologo -properties $Properties -parameters $Parameters
            } else {
                Invoke-psake -buildFile $psakeFile -taskList $Task -nologo -properties $Properties -parameters $Parameters -framework 4.7x64
            }
            exit ([int](-not $psake.build_success))
        }
    } finally {
        Pop-Location
        [Environment]::CurrentDirectory = $previousPWD
    }
}
