param($ModulePath)
if ([string]::IsNullOrWhiteSpace($ModulePath)) {
    return
}
Describe 'MilestonePSTools Integration Tests' {
    BeforeDiscovery {
        $script:SkipIntegrationTests = $true
        if (-not (Test-Path $ModulePath)) {
            $searchPath = [io.path]::Combine($env:BHProjectPath, 'Output', $env:BHProjectName, "$($env:BHProjectName).psd1")
            $ModulePath = (Get-ChildItem -Path $searchPath -Recurse -Depth 1 | Select-Object -First 1).FullName
        }
        try {
            Import-Module $ModulePath -ErrorAction Stop
            $script:SkipIntegrationTests = $false
        } catch {
            throw
        }

        $script:SkipReadWriteTests = $true
        try {
            $null = Get-Secret -Name MilestonePSTools.Connect.ServerAddress -ErrorAction Stop
            $null = Get-Secret -Name MilestonePSTools.Connect.WindowsCredential -ErrorAction Stop
            $script:SkipReadWriteTests = $false
        } catch {
            Write-Verbose -Message $_.Exception.Message
        }

        if ($script:SkipReadWriteTests) {
            $script:SkipIntegrationTests = $true
            Write-Host "Skipping integration tests" -ForegroundColor Yellow
        }

        Write-Verbose "SkipReadWriteTests = $script:SkipReadWriteTests"
        Write-Verbose "SkipIntegrationTests = $script:SkipIntegrationTests"
    }

    Context 'Read-Write Tests' {
        BeforeAll {
            Write-Host "Read-Write Tests.BeforeAll"
            $errorPref = $ErrorActionPreference
            try {
                $ErrorActionPreference = 'Stop'
                $ProgressPreference = 'SilentlyContinue'

                # This will throw and return false if the vault is locked
                $null = Test-SecretVault -Name secretstore

                $connectParams = @{
                    ServerAddress = Get-Secret -Vault secretstore -Name MilestonePSTools.Connect.ServerAddress -AsPlainText -ErrorAction Stop
                    Credential    = Get-Secret -Vault secretstore -Name MilestonePSTools.Connect.WindowsCredential -ErrorAction Stop
                    Force         = $true
                    ErrorAction   = 'Stop'
                    AcceptEula    = $true
                }
                Connect-ManagementServer @connectParams

                $recorder = Get-VmsRecordingServer | Select-Object -First 1
                $recorder | Get-VmsHardware | Remove-Hardware -Confirm:$false
                $cred = [pscredential]::new('a', ('a' | ConvertTo-SecureString -AsPlainText -Force))
                $script:StableFpsHardware = $recorder | Add-VmsHardware -HardwareAddress "http://localhost:5000" -Name 'MilestonePSTools.Tests' -DriverNumber 5000 -Credential $cred -Force | ForEach-Object {
                    $hw = $_
                    $fileKey = $hw.HardwareDriverSettingsFolder.HardwareDriverSettings[0].HardwareDriverSettingsChildItems[0].GetPropertyKeys() | Where-Object { $_ -match 'VideoH264Files' } | Select-Object -First 1
                    $file = $hw.HardwareDriverSettingsFolder.HardwareDriverSettings[0].HardwareDriverSettingsChildItems[0].GetValueTypeInfoList($fileKey) | Where-Object Value -ne 'None' | Select-Object -First 1 -ExpandProperty Value
                    $hw | Set-HardwareSetting -Name 'VideoCodec' -Value 'H264'
                    $hw | Set-HardwareSetting -Name 'VideoH264Files' -Value $file
                    $hw
                }
                $null = New-VmsDeviceGroup -Path /StableFPS | Add-VmsDeviceGroupMember -Device ($script:StableFpsHardware | Get-VmsCamera -EnableFilter All)
                Clear-VmsCache
            } finally {
                $ErrorActionPreference = $errorPref
            }
        }

        try {
            $secretNames = (Get-SecretInfo -Vault secretstore -ErrorAction Stop).Name
            $requiredSecrets = 'MilestonePSTools.Connect.ServerAddress', 'MilestonePSTools.Connect.WindowsCredential'
            $loadTests = ($requiredSecrets | Where-Object { $_ -in $secretNames }).Count -eq $requiredSecrets.Count
            if ($loadTests) {
                Get-ChildItem -Path $PSScriptRoot\read-write\*.integration.ps1 -Recurse -PipelineVariable file | Foreach-Object {
                    try {
                        . $file.FullName
                    } catch {
                        Write-Error "Failed to dot-source $($file.FullName). Error: $($_.Exception.Message)"
                    }
                }
            } else {
                Write-host "Integration tests will not be loaded because the credentials were not found in secretstore." -ForegroundColor Yellow
            }
        } catch {
            throw
        }
        
        

        AfterAll {
            Disconnect-ManagementServer
        }
    }
}
