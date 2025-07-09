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

function Invoke-ServerConfigurator {
    [CmdletBinding()]
    [RequiresVmsConnection($false)]
    [RequiresElevation()]
    param(
        # Enable encryption for the CertificateGroup specified
        [Parameter(ParameterSetName = 'EnableEncryption', Mandatory)]
        [switch]
        $EnableEncryption,

        # Disable encryption for the CertificateGroup specified
        [Parameter(ParameterSetName = 'DisableEncryption', Mandatory)]
        [switch]
        $DisableEncryption,

        # Specifies the CertificateGroup [guid] identifying which component for which encryption
        # should be enabled or disabled
        [Parameter(ParameterSetName = 'EnableEncryption')]
        [Parameter(ParameterSetName = 'DisableEncryption')]
        [guid]
        $CertificateGroup,

        # Specifies the thumbprint of the certificate to be used to encrypt communications with the
        # component designated by the CertificateGroup id.
        [Parameter(ParameterSetName = 'EnableEncryption', Mandatory)]
        [string]
        $Thumbprint,

        # List the available certificate groups on the local machine. Output will be a [hashtable]
        # where the keys are the certificate group names (which may contain spaces) and the values
        # are the associated [guid] id's.
        [Parameter(ParameterSetName = 'ListCertificateGroups')]
        [switch]
        $ListCertificateGroups,

        # Register all local components with the optionally specified AuthAddress. If no
        # AuthAddress is provided, the last-known address will be used.
        [Parameter(ParameterSetName = 'Register', Mandatory)]
        [switch]
        $Register,

        # Specifies the address of the Authorization Server which is usually the Management Server
        # address. A [uri] value is expected, but only the URI host value will be used. The scheme
        # and port will be inferred based on whether encryption is enabled/disabled and is fixed to
        # port 80/443 as this is how Server Configurator is currently designed.
        [Parameter(ParameterSetName = 'Register')]
        [uri]
        $AuthAddress,

        [Parameter(ParameterSetName = 'Register')]
        [switch]
        $OverrideLocalManagementServer,

        # Specifies the path to the Server Configurator utility. Omit this path and the path will
        # be discovered using Get-RecorderConfig or Get-ManagementServerConfig by locating the
        # installation path of the Management Server or Recording Server and assuming the Server
        # Configurator is located in the same path.
        [Parameter()]
        [string]
        $Path,

        # Specifies that the standard output from the Server Configurator utility should be written
        # after the operation is completed. The output will include the following properties:
        # - StandardOutput
        # - StandardError
        # - ExitCode
        [Parameter(ParameterSetName = 'EnableEncryption')]
        [Parameter(ParameterSetName = 'DisableEncryption')]
        [Parameter(ParameterSetName = 'Register')]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $exePath = $Path
        if ([string]::IsNullOrWhiteSpace($exePath)) {
            $cimSplat = @{
                ClassName = 'Win32_Service'
                Filter    = 'DisplayName like "Milestone XProtect%"'
            }
            $milestoneSvc = Get-CimInstance @cimSplat | Select-Object -First 1
            if ($null -eq $milestoneSvc) {
                Write-Error 'Automatic Server Configurator discovery failed: Could not find a Milestone XProtect service. Please provide the path to ServerConfigurator.exe using the Path parameter.'
                return
            }
            $milestoneSvcPath = $milestoneSvc.PathName.Trim(("'", '"'))
            $fileInfo = [io.fileinfo]::new($milestoneSvcPath)
            $exePath = Join-Path $fileInfo.Directory.Parent.FullName 'Server Configurator\serverconfigurator.exe'
            if (-not (Test-Path $exePath)) {
                Write-Error "Automatic Server Configurator discovery failed: Expected to find Server Configurator at '$exePath' but failed. Please provide the path to ServerConfigurator.exe using the Path parameter."
                return
            }
        }

        # Ensure version is 20.3 (2020 R3) or newer
        $fileInfo = [io.fileinfo]::new($exePath)
        if ($fileInfo.VersionInfo.FileVersion -lt [version]'20.3') {
            Write-Error "Invoke-ServerConfigurator requires Milestone version 2020 R3 or newer as this is when command-line options were introduced. Found Server Configurator version $($fileInfo.VersionInfo.FileVersion)"
            return
        }

        $exitCode = @{
            0  = 'Success'
            -1 = 'Unknown error'
            -2 = 'Invalid arguments'
            -3 = 'Invalid argument value'
            -4 = 'Another instance is running'
        }

        # Get Certificate Group list for either display to user or verification
        $output = Get-ProcessOutput -FilePath $exePath -ArgumentList /listcertificategroups
        if ($output.ExitCode -ne 0) {
            Write-Error "Server Configurator exited with code $($output.ExitCode). $($exitCode.($output.ExitCode))."
            Write-Error $output.StandardOutput
            return
        }
        Write-Information $output.StandardOutput
        $groups = @{}
        foreach ($line in $output.StandardOutput -split ([environment]::NewLine)) {
            if ($line -match "Found '(?<groupName>.+)' group with ID = (?<groupId>.{36})") {
                $groups.$($Matches.groupName) = [guid]::Parse($Matches.groupId)
            }
        }


        switch ($PSCmdlet.ParameterSetName) {
            'EnableEncryption' {
                if ($MyInvocation.BoundParameters.ContainsKey('CertificateGroup') -and $CertificateGroup -notin $groups.Values) {
                    Write-Error "CertificateGroup value '$CertificateGroup' not found. Use the ListCertificateGroups switch to discover valid CertificateGroup values"
                    return
                }

                $enableArgs = @('/quiet', '/enableencryption', "/thumbprint=$Thumbprint")
                if ($MyInvocation.BoundParameters.ContainsKey('CertificateGroup')) {
                    $enableArgs += "/certificategroup=$CertificateGroup"
                }
                $output = Get-ProcessOutput -FilePath $exePath -ArgumentList $enableArgs
                if ($output.ExitCode -ne 0) {
                    Write-Error "EnableEncryption failed. Server Configurator exited with code $($output.ExitCode). $($exitCode.($output.ExitCode))."
                    Write-Error $output.StandardOutput
                }
            }

            'DisableEncryption' {
                if ($MyInvocation.BoundParameters.ContainsKey('CertificateGroup') -and $CertificateGroup -notin $groups.Values) {
                    Write-Error "CertificateGroup value '$CertificateGroup' not found. Use the ListCertificateGroups switch to discover valid CertificateGroup values"
                    return
                }
                $disableArgs = @('/quiet', '/disableencryption')
                if ($MyInvocation.BoundParameters.ContainsKey('CertificateGroup')) {
                    $disableArgs += "/certificategroup=$CertificateGroup"
                }
                $output = Get-ProcessOutput -FilePath $exePath -ArgumentList $disableArgs
                if ($output.ExitCode -ne 0) {
                    Write-Error "EnableEncryption failed. Server Configurator exited with code $($output.ExitCode). $($exitCode.($output.ExitCode))."
                    Write-Error $output.StandardOutput
                }
            }

            'ListCertificateGroups' {
                Write-Output $groups
                return
            }

            'Register' {
                $registerArgs = @('/register', '/quiet')
                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('AuthAddress')) {
                    $registerArgs += '/managementserveraddress={0}' -f $AuthAddress.ToString()
                    if ($OverrideLocalManagementServer) {
                        $registerArgs += '/overridelocalmanagementserver'
                    }
                }
                $output = Get-ProcessOutput -FilePath $exePath -ArgumentList $registerArgs
                if ($output.ExitCode -ne 0) {
                    Write-Error "Registration failed. Server Configurator exited with code $($output.ExitCode). $($exitCode.($output.ExitCode))."
                    Write-Error $output.StandardOutput
                }
            }

            Default {
            }
        }

        Write-Information $output.StandardOutput
        if ($PassThru) {
            Write-Output $output
        }
    }
}

