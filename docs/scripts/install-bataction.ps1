$script = {
    $VerbosePreference = 'Continue'

# This scriptblock serves only as an example. It will log to C:\ProgramData\Milestone\BatAction, and save a camera report there.
$ps1Script = {
function ConvertFrom-BatAction {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter()]
        [string[]]
        $ArgumentList
    )

    process {
        $obj = [pscustomobject]@{
            SourceId   = [guid]::Empty
            SourceName = $null
            SourceType = $null
            Devices    = New-Object System.Collections.Generic.List[pscustomobject]
        }

        $index = 0
        if ($ArgumentList.Count -gt 0 -and $null -ne ($ArgumentList[0] -as [guid])) {
            $obj.SourceId = $ArgumentList[0] -as [guid]
            $obj.SourceName = $ArgumentList[1]
            $obj.SourceType = $ArgumentList[2]
            $index = 3
        }

        for (; $index -lt $ArgumentList.Count; $index++) {
            if ($ArgumentList[$index] -match '^Item=(?<id>[0-9a-fA-F\-]{36}) Name=(?<name>.+)$') {
                $obj.Devices.Add([pscustomobject]@{
                    Name = $Matches.name
                    Id   = $Matches.id
                })
            }
            else {
                Write-Error "Format of `$arg[$index] was unexpected. Expected ""Item=<guid> Name=<name>"" but received ""$($ArgumentList[$index])"""
            }
        }

        Write-Output $obj
    }
}

try {
    # Use Start-Transcript to log to C:\ProgramData\Milestone\BatAction\BatAction.log
    # Note: The log file gets re-written on every execution to keep things simple and avoid generating too many logs.
    $workingDir = Join-Path $env:ProgramData 'Milestone\BatAction\'
    $null = New-Item -Path $workingDir -ItemType Directory -Force
    $transactionLogPath = Join-Path $workingDir 'BatAction.log'
    Start-Transcript -Path $transactionLogPath


    <# The $args variable holds all arguments passed to the script. Here, we're calling the function
       above to parse the arguments into something that is easier to use in PowerShell.

       We won't use this object in this example, but you could for instance write a script tha
       uses MilestonePSTools to perform an export of video associated with a bookmark.

       The object returned by ConvertFrom-BatAction looks like...

       [guid]$SourceId (will be [guid]::Empty if the trigger was based on a schedule)
       [string]$SourceName (will be $null if the trigger was based on a schedule)
       [string]$SourceType (will be $null if the trigger was based on a schedule, otherwise usually 'Event' or 'Camera')
       [pscustomobject[]]$Devices (empty array, or a list of pscustomobjects each with a Name and Id property)
    #>
    $BatActionArgs = ConvertFrom-BatAction -ArgumentList $args
    Write-Host "The BatAction plugin provided the following data:`r`n$($BatActionArgs | ConvertTo-Json)`r`n"

    $timestamp = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')
    $fileName = "Camera-Report_$timestamp.csv"
    $reportPath = Join-Path -Path $workingDir -ChildPath $fileName

    Write-Host "Connecting to http://localhost as $($env:USERNAME)"
    Connect-Vms -AcceptEula
    Write-Host 'Connected'

    Write-Host "Running Get-VmsCameraReport and saving the results to $reportPath"
    Get-VmsCameraReport -Verbose | Export-Csv -Path $reportPath -NoTypeInformation
    Write-Host 'Done'
}
finally {
    Stop-Transcript
}
}

    $tempFile = Join-Path $env:temp 'BatAction.zip'
    $startEventServer = $false
    try {
        $workingDir = Join-Path $env:ProgramData 'Milestone\BatAction\'
        $null = New-Item -Path $workingDir -ItemType Directory -Force
        $transactionLogPath = Join-Path $workingDir 'BatAction-Install.log'
        Start-Transcript -Path $transactionLogPath

        $url = 'https://download.milestonesys.com/mipsdk/BatAction_v21.2.zip'

        $destination = Join-Path $env:SystemDrive 'Program Files\VideoOS\MIPPlugins\'
        Write-Host "Saving BatAction.zip to $tempFile"
        Invoke-RestMethod -Method Get -Uri $url -OutFile $tempFile
        Unblock-File -Path $tempFile


        $eventServer = Get-Service -Name MilestoneEventServerService -ErrorAction SilentlyContinue
        if ($eventServer -and $eventServer.Status -ne 'Stopped') {
            Write-Host 'Stopping the Milestone Event Server service'
            $eventServer | Stop-Service -Force
            $startEventServer = $true
        }

        Write-Host "Extracting BatAction.zip to $destination"
        for ($tries = 1; $tries -le 3; $tries++) {
            try {
                Expand-Archive -Path $tempFile -DestinationPath $destination -Force -ErrorAction Stop
                break
            } catch {
                if ($tries -ge 3) {
                    throw
                }
                Write-Host 'Error extracting BatAction.zip. Retrying in 5 seconds. . .' -ForegroundColor DarkRed
                Start-Sleep -Seconds 5
            }
        }


        Write-Host 'Replacing Sample.bat with CameraReport.bat'
        $batFolder = Join-Path $destination 'BatAction\BatFiles\'
        Get-ChildItem -Path $batFolder | Remove-Item -Force
        $ps1Folder = Join-Path $destination 'BatAction\Ps1Files\'
        $null = New-Item -Path $ps1Folder -ItemType Directory -Force
        $batFile = Join-Path $batFolder 'CameraReport.bat'
        $ps1File = Join-Path $ps1Folder 'CameraReport.ps1'

        'powershell.exe -ExecutionPolicy Bypass -NoProfile -NonInteractive -NoLogo -File "%~dp0..\Ps1Files\%~n0.ps1" %*' | Set-Content -Path $batFile -Force
        $ps1Script.ToString() | Set-Content -Path $ps1File -Force

    } finally {
        if (Test-Path $tempFile) {
            Write-Host "Deleting temporary file $tempFile"
            Remove-Item -Path $tempFile -Force
        }
        if ($eventServer -and $startEventServer) {
            Write-Host 'Starting the Milestone Event Server service'
            $eventServer | Start-Service
        }
        Write-Host 'Done.'
        Stop-Transcript
        Invoke-Item $transactionLogPath
    }
}
$encodedCommand = [Convert]::ToBase64String([text.encoding]::Unicode.GetBytes($script))
Start-Process -FilePath powershell.exe -ArgumentList "-encodedCommand $encodedCommand" -Verb RunAs
