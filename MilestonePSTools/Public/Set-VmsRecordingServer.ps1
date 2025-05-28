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

function Set-VmsRecordingServer {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [Alias('Recorder')]
        [RecorderNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.RecordingServer[]]
        $RecordingServer,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [BooleanTransformAttribute()]
        [bool]
        $PublicAccessEnabled,

        [Parameter()]
        [ValidateRange(0, 65535)]
        [int]
        $PublicWebserverPort,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $PublicWebserverHostName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [BooleanTransformAttribute()]
        [bool]
        $ShutdownOnStorageFailure,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $MulticastServerAddress,

        [Parameter()]
        [ValidateVmsFeature('RecordingServerFailover')]
        [FailoverGroupNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.FailoverGroup]
        $PrimaryFailoverGroup,

        [Parameter()]
        [ValidateVmsFeature('RecordingServerFailover')]
        [FailoverGroupNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.FailoverGroup]
        $SecondaryFailoverGroup,

        [Parameter()]
        [ValidateVmsFeature('RecordingServerFailover')]
        [FailoverRecorderNameTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.FailoverRecorder]
        $HotStandbyFailoverRecorder,

        [Parameter()]
        [ValidateVmsFeature('RecordingServerFailover')]
        [switch]
        $DisableFailover,

        [Parameter()]
        [ValidateVmsFeature('RecordingServerFailover')]
        [ValidateRange(0, 65535)]
        [int]
        $FailoverPort,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
        $updateFailoverSettings = $false
        'PrimaryFailoverGroup', 'SecondaryFailoverGroup', 'HotStandbyFailoverRecorder', 'DisableFailover', 'FailoverPort' | Foreach-Object {
            if ($MyInvocation.BoundParameters.ContainsKey($_)) {
                $updateFailoverSettings = $true
            }
        }
    }

    process {
        if ($HotStandbyFailoverRecorder -and ($PrimaryFailoverGroup -or $SecondaryFailoverGroup)) {
            throw "Invalid combination of failover parameters. When specifying a hot standby failover recorder, you may not also assign a primary or secondary failover group."
        }
        if ($PrimaryFailoverGroup -and ($PrimaryFailoverGroup.Path -eq $SecondaryFailoverGroup.Path)) {
            throw "The same failover group cannot be used for both the primary, and secondary failover groups."
        }

        foreach ($rec in $RecordingServer) {
            try {
                foreach ($property in $rec | Get-Member -MemberType Property | Where-Object Definition -like '*set;*' | Select-Object -ExpandProperty Name) {
                    $parameterName = $property
                    if (-not $PSBoundParameters.ContainsKey($parameterName)) {
                        continue
                    }
                    $newValue = $PSBoundParameters[$parameterName]
                    if ($newValue -ceq $rec.$property) {
                        continue
                    }
                    if ($PSCmdlet.ShouldProcess($rec.Name, "Set $property to $newValue")) {
                        $rec.$property = $newValue
                        $dirty = $true
                    }
                }

                if ($updateFailoverSettings) {

                    $dirtyFailover = $false
                    $failoverSettings = $rec.RecordingServerFailoverFolder.recordingServerFailovers[0]

                    if ($MyInvocation.BoundParameters.ContainsKey('PrimaryFailoverGroup') -and $PrimaryFailoverGroup.Path -ne $failoverSettings.PrimaryFailoverGroup) {
                        $targetName, $targetPath = $PrimaryFailoverGroup.Name, $PrimaryFailoverGroup.Path
                        if ($null -eq $targetName) {
                            $targetName, $targetPath = 'Not used', $failoverSettings.PrimaryFailoverGroupValues['Not used']
                        }

                        if ($PSCmdlet.ShouldProcess($rec.Name, "Set PrimaryFailoverGroup to $targetName")) {
                            $failoverSettings.PrimaryFailoverGroup = $targetPath
                            $failoverSettings.HotStandby = $failoverSettings.HotStandbyValues['Not used']
                            if ($targetPath -eq $failoverSettings.PrimaryFailoverGroupValues['Not used']) {
                                $failoverSettings.SecondaryFailoverGroup = $failoverSettings.SecondaryFailoverGroupValues['Not used']
                            }
                            $dirtyFailover = $true
                        }
                    }

                    if ($MyInvocation.BoundParameters.ContainsKey('SecondaryFailoverGroup') -and $SecondaryFailoverGroup.Path -ne $failoverSettings.SecondaryFailoverGroup) {
                        $targetName, $targetPath = $SecondaryFailoverGroup.Name, $SecondaryFailoverGroup.Path
                        if ($null -eq $targetName) {
                            $targetName, $targetPath = 'Not used', $failoverSettings.SecondaryFailoverGroupValues['Not used']
                        }

                        if ($failoverSettings.PrimaryFailoverGroup -eq 'FailoverGroup[00000000-0000-0000-0000-000000000000]') {
                            Write-Error -Message "You must specify a primary failover group to set the secondary failover group."
                        } elseif ($targetPath -eq $failoverSettings.PrimaryFailoverGroup) {
                            Write-Error -Message "The PrimaryFailoverGroup and SecondaryFailoverGroup must not be the same."
                        } elseif ($PSCmdlet.ShouldProcess($rec.Name, "Set SecondaryFailoverGroup to $targetName")) {
                            $failoverSettings.SecondaryFailoverGroup = $targetPath
                            $failoverSettings.HotStandby = $failoverSettings.HotStandbyValues['Not used']
                            $dirtyFailover = $true
                        }
                    }

                    if ($MyInvocation.BoundParameters.ContainsKey('HotStandbyFailoverRecorder') -and $HotStandbyFailoverRecorder.Path -ne $failoverSettings.HotStandby) {
                        $targetName, $targetPath = $HotStandbyFailoverRecorder.Name, $HotStandbyFailoverRecorder.Path
                        if ($null -eq $targetName) {
                            $targetName, $targetPath = 'Not used', $failoverSettings.HotStandbyValues['Not used']
                        }

                        if ($PSCmdlet.ShouldProcess($rec.Name, "Set hot standby server to $targetName")) {
                            $failoverSettings.PrimaryFailoverGroup = $failoverSettings.PrimaryFailoverGroupValues['Not used']
                            $failoverSettings.SecondaryFailoverGroup = $failoverSettings.SecondaryFailoverGroupValues['Not used']

                            if (-not [string]::IsNullOrWhiteSpace($failoverSettings.HotStandby)) {
                                # Fix for bug #593838. If bug is fixed, consider adding a version check and skip this extra call to Save()
                                $failoverSettings.HotStandby = $failoverSettings.HotStandbyValues['Not used']
                                $failoverSettings.Save()
                            }
                            $failoverSettings.HotStandby = $targetPath
                            $dirtyFailover = $true
                        }
                    }

                    if ($DisableFailover) {
                        if ($PSCmdlet.ShouldProcess($rec.Name, "Disable failover recording")) {
                            $failoverSettings.PrimaryFailoverGroup = $failoverSettings.PrimaryFailoverGroupValues['Not used']
                            $failoverSettings.SecondaryFailoverGroup = $failoverSettings.SecondaryFailoverGroupValues['Not used']
                            $failoverSettings.HotStandby = $failoverSettings.HotStandbyValues['Not used']
                            $dirtyFailover = $true
                        }
                    }

                    if ($MyInvocation.BoundParameters.ContainsKey('FailoverPort') -and $FailoverPort -ne $failoverSettings.FailoverPort) {
                        if ($PSCmdlet.ShouldProcess($rec.Name, "Set failover port to $FailoverPort")) {
                            $failoverSettings.FailoverPort = $FailoverPort
                            $dirtyFailover = $true
                        }
                    }

                    if ($dirtyFailover) {
                        $failoverSettings.Save()
                    }
                }

                if ($dirty) {
                    $rec.Save()
                }

                if ($PassThru) {
                    $rec
                }
            } catch [VideoOS.Platform.Proxy.ConfigApi.ValidateResultException] {
                $rec.RecordingServerFailoverFolder.ClearChildrenCache()
                $_ | HandleValidateResultException -TargetObject $rec -ItemName $rec.Name
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Set-VmsRecordingServer -ParameterName RecordingServer -ScriptBlock {
    $values = (Get-VmsRecordingServer).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

Register-ArgumentCompleter -CommandName Set-VmsRecordingServer -ParameterName PrimaryFailoverGroup -ScriptBlock {
    $values = (Get-VmsFailoverGroup).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

Register-ArgumentCompleter -CommandName Set-VmsRecordingServer -ParameterName SecondaryFailoverGroup -ScriptBlock {
    $values = (Get-VmsFailoverGroup).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

Register-ArgumentCompleter -CommandName Set-VmsRecordingServer -ParameterName HotStandbyFailoverRecorder -ScriptBlock {
    $values = (Get-VmsFailoverRecorder -Unassigned).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

