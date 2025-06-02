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

function Start-VmsHardwareScan {
    [CmdletBinding()]
    [OutputType([VmsHardwareScanResult])]
    [RequiresVmsConnection()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter([MipItemNameCompleter[RecordingServer]])]
        [MipItemTransformation([RecordingServer])]
        [RecordingServer[]]
        $RecordingServer,

        [Parameter(Mandatory, ParameterSetName = 'Express')]
        [switch]
        $Express,

        [Parameter(ParameterSetName = 'Manual')]
        [uri[]]
        $Address = @(),

        [Parameter(ParameterSetName = 'Manual')]
        [ipaddress]
        $Start,

        [Parameter(ParameterSetName = 'Manual')]
        [ipaddress]
        $End,

        [Parameter(ParameterSetName = 'Manual')]
        [string]
        $Cidr,

        [Parameter(ParameterSetName = 'Manual')]
        [int]
        $HttpPort = 80,

        [Parameter(ParameterSetName = 'Manual')]
        [int[]]
        $DriverNumber = @(),

        [Parameter(ParameterSetName = 'Manual')]
        [string[]]
        $DriverFamily,

        [Parameter()]
        [pscredential[]]
        $Credential,

        [Parameter()]
        [switch]
        $UseDefaultCredentials,

        [Parameter()]
        [switch]
        $UseHttps,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $tasks = @()
        $recorderPathMap = @{}
        $progressParams = @{
            Activity        = 'Initiating VMS hardware scan'
            PercentComplete = 0
        }
        Write-Progress @progressParams
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'Express' {
                    foreach ($credentialSet in $Credential | BuildGroupsOfGivenSize -GroupSize 3 -EmptyItem $null) {
                        try {
                            $credentials = $credentialSet | ForEach-Object {
                                [pscustomobject]@{
                                    UserName = $_.UserName
                                    Password = if ($null -eq $_) { $null } else { $_.GetNetworkCredential().Password }
                                }
                            }
                            foreach ($recorder in $RecordingServer) {
                                $recorderPathMap.($recorder.Path) = $recorder
                                $tasks += $recorder.HardwareScanExpress(
                                    $credentials[0].UserName, $credentials[0].Password,
                                    $credentials[1].UserName, $credentials[1].Password,
                                    $credentials[2].UserName, $credentials[2].Password,
                                    ($null -eq $Credential -or $UseDefaultCredentials), $UseHttps)
                            }
                        } catch {
                            throw
                        }
                    }
                }

                'Manual' {
                    $rangeParameters = ($MyInvocation.BoundParameters.Keys | Where-Object { $_ -in @('Start', 'End') }).Count
                    if ($rangeParameters -eq 1) {
                        Write-Error 'When using the Start or End parameters, you must provide both Start and End parameter values'
                        return
                    }

                    $Address = $Address | ForEach-Object {
                        if ($_.IsAbsoluteUri) {
                            $_
                        } else {
                            [uri]"http://$($_.OriginalString)"
                        }
                    }
                    if ($MyInvocation.BoundParameters.ContainsKey('UseHttps') -or $MyInvocation.BoundParameters.ContainsKey('HttpPort')) {
                        $Address = $Address | Foreach-Object {
                            $a = [uribuilder]$_
                            if ($MyInvocation.BoundParameters.ContainsKey('UseHttps')) {
                                $a.Scheme = if ($UseHttps) { 'https' } else { 'http' }
                            }
                            if ($MyInvocation.BoundParameters.ContainsKey('HttpPort')) {
                                $a.Port = $HttpPort
                            }
                            $a.Uri
                        }
                    }
                    if ($MyInvocation.BoundParameters.ContainsKey('Start')) {
                        $Address += Expand-IPRange -Start $Start -End $End | ConvertTo-Uri -UseHttps:$UseHttps -HttpPort $HttpPort
                    }
                    if ($MyInvocation.BoundParameters.ContainsKey('Cidr')) {
                        $Address += Expand-IPRange -Cidr $Cidr | Select-Object -Skip 1 | Select-Object -SkipLast 1 | ConvertTo-Uri -UseHttps:$UseHttps -HttpPort $HttpPort
                    }

                    foreach ($entry in $Address) {
                        try {
                            foreach ($cred in $Credential | BuildGroupsOfGivenSize -GroupSize 1 -EmptyItem $null) {
                                $user = $cred[0].UserName
                                $pass = $cred[0].Password
                                foreach ($recorder in $RecordingServer) {
                                    if ($MyInvocation.BoundParameters.ContainsKey('DriverFamily')) {
                                        $DriverNumber += $recorder | Get-VmsHardwareDriver | Where-Object { $_.GroupName -in $DriverFamily -and $_.Number -notin $DriverNumber } | Select-Object -ExpandProperty Number
                                    }
                                    if ($DriverNumber.Count -eq 0) {
                                        Write-Warning "Start-VmsHardwareScan is about to scan $($Address.Count) addresses from $($recorder.Name) without specifying one or more hardware device drivers. This can take a very long time."
                                    }
                                    $driverNumbers = $DriverNumber -join ';'
                                    Write-Verbose "Adding HardwareScan task for $($entry) using driver numbers $driverNumbers"
                                    $recorderPathMap.($recorder.Path) = $recorder
                                    $tasks += $RecordingServer.HardwareScan($entry.ToString(), $driverNumbers, $user, $pass, ($null -eq $Credential -or $UseDefaultCredentials))
                                }
                            }
                        } catch {
                            throw
                        }
                    }
                }
            }
        } finally {
            $progressParams.Completed = $true
            $progressParams.PercentComplete = 100
            Write-Progress @progressParams
        }

        if ($PassThru) {
            Write-Output $tasks
        } else {
            Wait-VmsTask -Path $tasks.Path -Title "Running $(($PSCmdlet.ParameterSetName).ToLower()) hardware scan" -Cleanup | Foreach-Object {
                $state = $_.Properties | Where-Object Key -eq 'State'
                if ($state.Value -eq 'Error') {
                    $errorText = $_.Properties | Where-Object Key -eq 'ErrorText'
                    Write-Error $errorText.Value
                } else {
                    $results = if ($_.Children.Count -gt 0) { [VmsHardwareScanResult[]]$_.Children } else {
                        [VmsHardwareScanResult]$_
                    }
                    foreach ($result in $results) {
                        $result.RecordingServer = $recorderPathMap.($_.ParentPath)
                        # TODO: Remove this entire if block when bug 487881 is fixed and hotfixes for supported versions are available.
                        if ($result.MacAddressExistsLocal) {
                            if ($result.MacAddress -notin ($result.RecordingServer | Get-VmsHardware | Get-HardwareSetting).MacAddress) {
                                Write-Verbose "MacAddress $($result.MacAddress) incorrectly reported as already existing on recorder. Changing MacAddressExistsLocal to false."
                                $result.MacAddressExistsLocal = $false
                            }
                        }
                        Write-Output $result
                    }
                }
            }
        }
    }
}
