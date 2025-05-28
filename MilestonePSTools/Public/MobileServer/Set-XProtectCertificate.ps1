# Copyright 2025 Milestone Systems A/S
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function Set-XProtectCertificate {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection($false)]
    [RequiresElevation()]
    param (
        # Specifies the Milestone component on which to update the certificate
        # - Server: Applies to communication between Management Server and Recording Server, as well as client connections to the HTTPS port for the Management Server.
        # - StreamingMedia: Applies to all connections to Recording Servers. Typically on port 7563.
        # - MobileServer: Applies to HTTPS connections to the Milestone Mobile Server.
        [Parameter(Mandatory)]
        [ValidateSet('Server', 'StreamingMedia', 'MobileServer', 'EventServer')]
        [string]
        $VmsComponent,

        # Specifies that encryption for the specified Milestone XProtect service should be disabled
        [Parameter(ParameterSetName = 'Disable')]
        [switch]
        $Disable,

        # Specifies the thumbprint of the certificate to apply to Milestone XProtect service
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'Enable')]
        [string]
        $Thumbprint,

        # Specifies the Windows user account for which read access to the private key is required
        [Parameter(ParameterSetName = 'Enable')]
        [string]
        $UserName,

        # Specifies the path to the Milestone Server Configurator executable. The default location is C:\Program Files\Milestone\Server Configurator\ServerConfigurator.exe
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $ServerConfiguratorPath = 'C:\Program Files\Milestone\Server Configurator\ServerConfigurator.exe',

        # Specifies that all certificates issued to
        [Parameter(ParameterSetName = 'Enable')]
        [switch]
        $RemoveOldCert,

        # Specifies that the Server Configurator process should be terminated if it's currently running
        [switch]
        $Force
    )

    begin {
        Assert-VmsRequirementsMet

        $certGroups = @{
            Server         = '84430eb7-847c-422d-aa00-7915cd0d7a65'
            StreamingMedia = '549df21d-047c-456b-958e-99e65dd8b3ec'
            MobileServer   = '76cfc719-a852-4210-913e-703eadab139a'
            EventServer    = '7e02e0f5-549d-4113-b8de-bda2c1f38dbf'
        }

        $knownExitCodes = @{
            0  = 'Success'
            -1 = 'Unknown error'
            -2 = 'Invalid arguments'
            -3 = 'Invalid argument value'
            -4 = 'Another instance is running'
        }
    }

    process {
        $utility = [IO.FileInfo]$ServerConfiguratorPath
        if (-not $utility.Exists) {
            $exception = [System.IO.FileNotFoundException]::new("Milestone Server Configurator not found at $ServerConfiguratorPath", $utility.FullName)
            Write-Error -Message $exception.Message -Exception $exception
            return
        }
        if ($utility.VersionInfo.FileVersion -lt [version]'20.3') {
            Write-Error "Server Configurator version 20.3 is required as the command-line interface for Server Configurator was introduced in version 2020 R3. The current version appears to be $($utility.VersionInfo.FileVersion). Please upgrade to version 2020 R3 or greater."
            return
        }
        Write-Verbose "Verified Server Configurator version $($utility.VersionInfo.FileVersion) is available at $ServerConfiguratorPath"

        $newCert = Get-ChildItem -Path "Cert:\LocalMachine\My\$Thumbprint" -ErrorAction Ignore
        if ($null -eq $newCert -and -not $Disable) {
            Write-Error "Certificate not found in Cert:\LocalMachine\My with thumbprint '$Thumbprint'. Please make sure the certificate is installed in the correct certificate store."
            return
        } elseif ($Thumbprint) {
            Write-Verbose "Located certificate in Cert:\LocalMachine\My with thumbprint $Thumbprint"
        }

        # Add read access to the private key for the specified certificate if UserName was specified
        if (-not [string]::IsNullOrWhiteSpace($UserName)) {
            try {
                Write-Verbose "Ensuring $UserName has the right to read the private key for the specified certificate"
                $newCert | Set-CertKeyPermission -UserName $UserName
            } catch {
                Write-Error -Message "Error granting user '$UserName' read access to the private key for certificate with thumbprint $Thumbprint" -Exception $_.Exception
            }
        }

        if ($Force) {
            if ($PSCmdlet.ShouldProcess("ServerConfigurator", "Kill process if running")) {
                Get-Process -Name ServerConfigurator -ErrorAction Ignore | Foreach-Object {
                    Write-Verbose 'Server Configurator is currently running. The Force switch was provided so it will be terminated.'
                    $_ | Stop-Process
                }
            }
        }

        $procParams = @{
            FilePath               = $utility.FullName
            Wait                   = $true
            PassThru               = $true
            RedirectStandardOutput = Join-Path -Path ([system.environment]::GetFolderPath([system.environment+specialfolder]::ApplicationData)) -ChildPath ([io.path]::GetRandomFileName())
        }
        if ($Disable) {
            $procParams.ArgumentList = '/quiet', '/disableencryption', "/certificategroup=$($certGroups.$VmsComponent)"
        } else {
            $procParams.ArgumentList = '/quiet', '/enableencryption', "/certificategroup=$($certGroups.$VmsComponent)", "/thumbprint=$Thumbprint"
        }
        $argumentString = [string]::Join(' ', $procParams.ArgumentList)
        Write-Verbose "Running Server Configurator with the following arguments: $argumentString"

        if ($PSCmdlet.ShouldProcess("ServerConfigurator", "Start process with arguments '$argumentString'")) {
            $result = Start-Process @procParams
            if ($result.ExitCode -ne 0) {
                Write-Error "Server Configurator exited with code $($result.ExitCode). $($knownExitCodes.$($result.ExitCode))"
                return
            }
        }

        if ($RemoveOldCert) {
            $oldCerts = Get-ChildItem -Path "Cert:\LocalMachine\My" | Where-Object { $_.Subject -eq $newCert.Subject -and $_.Thumbprint -ne $newCert.Thumbprint }
            if ($null -eq $oldCerts) {
                Write-Verbose "No other certificates found matching the subject name $($newCert.Subject)"
                return
            }
            foreach ($cert in $oldCerts) {
                if ($PSCmdlet.ShouldProcess($cert.Thumbprint, "Remove certificate from certificate store")) {
                    Write-Verbose "Removing certificate with thumbprint $($cert.Thumbprint)"
                    $cert | Remove-Item
                }
            }
        }
    }
}

