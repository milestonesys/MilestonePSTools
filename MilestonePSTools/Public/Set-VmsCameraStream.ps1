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

function Set-VmsCameraStream {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'RemoveStream')]
        [switch]
        $Disabled,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'AddOrUpdateStream')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'RemoveStream')]
        [VmsCameraStreamConfig[]]
        $Stream,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [string]
        $DisplayName,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [ValidateSet('Always', 'Never', 'WhenNeeded')]
        [string]
        $LiveMode,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [switch]
        $LiveDefault,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [switch]
        $Recorded,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [ValidateSet('Primary', 'Secondary', 'None')]
        [string]
        $RecordingTrack,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [ValidateVmsVersion('23.2')]
        [ValidateVmsFeature('MultistreamRecording')]
        [switch]
        $PlaybackDefault,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [switch]
        $UseEdge,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [hashtable]
        $Settings
    )

    begin {
        Assert-VmsRequirementsMet

        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Recorded') -and $Recorded) {
            Write-Warning "The 'Recorded' switch parameter is deprecated with MilestonePSTools version 2023 R2 and later due to the added support for adaptive playback. For compatibility reasons, the '-Recorded' switch has the same meaning as '-RecordingTrack Primary -PlaybackDefault' unless one or both of these parameters were also specified."
            if (-not $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('RecordingTrack')) {
                Write-Verbose "Setting RecordingTrack parameter to 'Primary'"
                $PSCmdlet.MyInvocation.BoundParameters['RecordingTrack'] = $RecordingTrack = 'Primary'
            }
            if (-not $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('PlaybackDefault')) {
                Write-Verbose "Setting PlaybackDefault parameter to `$true"
                $PSCmdlet.MyInvocation.BoundParameters['PlaybackDefault'] = $PlaybackDefault = [switch]::new($true)
            }
            $null = $PSCmdlet.MyInvocation.BoundParameters.Remove('Recorded')
            Remove-Variable -Name 'Recorded'
        }
        $updatedItems = [system.collections.generic.list[pscustomobject]]::new()
        $itemCache = @{}
    }

    process {
        foreach ($s in $Stream) {
            $target = "$($s.Name) on $($s.Camera.Name)"
            $deviceDriverSettings = $s.Camera.DeviceDriverSettingsFolder.DeviceDriverSettings[0]
            if ($itemCache.ContainsKey($deviceDriverSettings.Path)) {
                $deviceDriverSettings = $itemCache[$deviceDriverSettings.Path]
            } else {
                $itemCache[$deviceDriverSettings.Path] = $deviceDriverSettings
            }
            $streamUsages = $s.Camera.StreamFolder.Streams | Select-Object -First 1
            if ($null -ne $streamUsages -and $itemCache.ContainsKey($streamUsages.Path)) {
                $streamUsages = $itemCache[$streamUsages.Path]
            } elseif ($null -ne $streamUsages) {
                $itemCache[$streamUsages.Path] = $streamUsages
            }

            $streamRefToName = @{}
            if ($streamUsages.StreamUsageChildItems.Count -gt 0) {
                $streamNameToRef = $streamUsages.StreamUsageChildItems[0].StreamReferenceIdValues
                foreach ($key in $streamNameToRef.Keys) {
                    $streamRefToName[$streamNameToRef.$key] = $key
                }
                $streamUsageChildItem = $streamUsages.StreamUsageChildItems | Where-Object StreamReferenceId -eq $streamNameToRef[$s.Name]
            }

            if ($PSCmdlet.ParameterSetName -eq 'RemoveStream' -and $null -ne $streamUsageChildItem -and $PSCmdlet.ShouldProcess($s.Camera.Name, "Disabling stream '$($s.Name)'")) {
                if ($streamUsages.StreamUsageChildItems.Count -eq 1) {
                    Write-Error "Stream $($s.Name) cannot be removed because it is the only enabled stream."
                } else {
                    $result = $streamUsages.RemoveStream($streamUsageChildItem.StreamReferenceId)
                    if ($result.State -eq 'Success') {
                        $s.Update()
                        $streamUsages = $s.Camera.StreamFolder.Streams[0]
                        $itemCache[$streamUsages.Path] = $streamUsages
                    } else {
                        Write-Error $result.ErrorText
                    }
                }
            } elseif ($PSCmdlet.ParameterSetName -eq 'AddOrUpdateStream') {
                $dirtyStreamUsages = $false
                $parametersRequiringStreamUsage = @('DisplayName', 'LiveDefault', 'LiveMode', 'PlaybackDefault', 'Recorded', 'RecordingTrack', 'UseEdge')
                if ($null -eq $streamUsageChildItem -and ($PSCmdlet.MyInvocation.BoundParameters.Keys | Where-Object { $_ -in $parametersRequiringStreamUsage } ) -and $PSCmdlet.ShouldProcess($s.Camera.Name, 'Adding a new stream usage')) {
                    try {
                        $result = $streamUsages.AddStream()
                        if ($result.State -ne 'Success') {
                            throw $result.ErrorText
                        }
                        $s.Update()
                        $streamUsages = $s.Camera.StreamFolder.Streams[0]
                        $itemCache[$streamUsages.Path] = $streamUsages
                        $streamUsageChildItem = $streamUsages.StreamUsageChildItems | Where-Object StreamReferenceId -eq $result.GetProperty('StreamReferenceId')
                        $streamUsageChildItem.StreamReferenceId = $streamNameToRef[$s.Name]
                        $streamUsageChildItem.Name = $s.Name
                        $dirtyStreamUsages = $true
                    } catch {
                        Write-Error $_
                    }
                }

                if ($RecordingTrack -eq 'Secondary' -and $streamUsageChildItem.RecordToValues.Count -eq 0) {
                    Write-Error "Adaptive playback is not available. RecordingTrack parameter must be Primary or None."
                    continue
                }

                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('DisplayName') -and $DisplayName -ne $streamUsageChildItem.Name) {
                    if ($PSCmdlet.ShouldProcess($s.Camera.Name, "Setting DisplayName on $($streamUsageChildItem.Name)")) {
                        $streamUsageChildItem.Name = $DisplayName
                    }
                    $dirtyStreamUsages = $true
                }

                $recordingTrackId = @{
                    Primary   = '16ce3aa1-5f93-458a-abe5-5c95d9ed1372'
                    Secondary = '84fff8b9-8cd1-46b2-a451-c4a87d4cbbb0'
                    None      = ''
                }
                $compatibilityRecord = if ($RecordingTrack -eq 'Primary') { $true } else { $false }
                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('RecordingTrack') -and (($streamUsageChildItem.RecordToValues.Count -gt 0 -and $recordingTrackId[$RecordingTrack] -ne $streamUsageChildItem.RecordTo) -or ($streamUsageChildItem.RecordToValues.Count -eq 0 -and $compatibilityRecord -ne $streamUsageChildItem.Record))) {
                    if ($streamUsageChildItem.RecordToValues.Count -gt 0) {
                        # 2023 R2 or later
                        $primaryStreamUsage = $streamUsages.StreamUsageChildItems | Where-Object RecordTo -eq $recordingTrackId.Primary
                        $secondaryStreamUsage = $streamUsages.StreamUsageChildItems | Where-Object RecordTo -eq $recordingTrackId.Secondary
                        switch ($RecordingTrack) {
                            'Primary' {
                                if ($PSCmdlet.ShouldProcess($s.Camera.Name, "Record $($streamUsageChildItem.Name) to the primary recording track")) {
                                    $streamUsageChildItem.RecordTo = $recordingTrackId.Primary

                                    Write-Verbose "Disabling recording on current primary stream '$($primaryStreamUsage.Name)'."
                                    $primaryStreamUsage.RecordTo = $recordingTrackId.None

                                    if ($primaryStreamUsage.LiveMode -eq 'Never') {
                                        Write-Verbose "Changing LiveMode from Never to WhenNeeded on $($primaryStreamUsage.Name)"
                                        $primaryStreamUsage.LiveMode = 'WhenNeeded'
                                    }

                                    if ($streamUsageChildItem.LiveMode -eq 'Never') {
                                        Write-Verbose "Changing LiveMode from Never to WhenNeeded on $($streamUsageChildItem.Name)"
                                        $streamUsageChildItem.LiveMode = 'WhenNeeded'
                                    }

                                    $dirtyStreamUsages = $true
                                }
                            }
                            'Secondary' {
                                if ($PSCmdlet.ShouldProcess($s.Camera.Name, "Record $($streamUsageChildItem.Name) to the secondary recording track")) {
                                    $streamUsageChildItem.RecordTo = $recordingTrackId.Secondary
                                    if ($streamUsageChildItem.LiveMode -eq 'Never') {
                                        Write-Verbose "Changing LiveMode from Never to WhenNeeded on $($streamUsageChildItem.Name)"
                                        $streamUsageChildItem.LiveMode = 'WhenNeeded'
                                    }

                                    if ($secondaryStreamUsage) {
                                        Write-Verbose "Disabling recording on current secondary stream '$($secondaryStreamUsage.Name)'."
                                        $secondaryStreamUsage.RecordTo = $recordingTrackId.None

                                        if ($secondaryStreamUsage.LiveMode -eq 'Never') {
                                            Write-Verbose "Changing LiveMode from Never to WhenNeeded on $($secondaryStreamUsage.Name)"
                                            $secondaryStreamUsage.LiveMode = 'WhenNeeded'
                                        }
                                    }

                                    $dirtyStreamUsages = $true
                                }
                            }
                            'None' {
                                if ($PSCmdlet.ShouldProcess($s.Camera.Name, "Disable recording of stream $($streamUsageChildItem.Name)")) {
                                    $streamUsageChildItem.RecordTo = $recordingTrackId.None
                                    if ($streamUsageChildItem.LiveMode -eq 'Never') {
                                        Write-Verbose "Changing LiveMode from Never to WhenNeeded on $($streamUsageChildItem.Name)"
                                        $streamUsageChildItem.LiveMode = 'WhenNeeded'
                                    }

                                    $streamUsages.StreamUsageChildItems | Where-Object {
                                        $_.StreamReferenceId -ne $streamUsageChildItem.StreamReferenceId -and -not [string]::IsNullOrWhiteSpace($_.RecordTo)
                                    } | Select-Object -First 1 | ForEach-Object {
                                        Write-Verbose "Setting the default playback stream to $($_.Name)"
                                        $_.DefaultPlayback = $true
                                    }

                                    $dirtyStreamUsages = $true
                                }
                            }
                        }
                    } else {
                        # 2023 R1 or earlier
                        $recordedStream = $streamUsages.StreamUsageChildItems | Where-Object Record
                        if ($PSCmdlet.ShouldProcess($s.Camera.Name, "Disabling recording on $($recordedStream.Name)")) {
                            $recordedStream.Record = $false
                            if ($recordedStream.LiveMode -eq 'Never' -and $PSCmdlet.ShouldProcess($s.Camera.Name, "Changing LiveMode from Never to WhenNeeded on $($recordedStream.Name)")) {
                                # This avoids a validation exception error.
                                $recordedStream.LiveMode = 'WhenNeeded'
                            }
                        }

                        if ($PSCmdlet.ShouldProcess($s.Camera.Name, "Enabling recording on $($streamUsageChildItem.Name)")) {
                            $streamUsageChildItem.Record = $true
                            $dirtyStreamUsages = $true
                        }
                    }
                }

                if ($PlaybackDefault -and $PlaybackDefault -ne $streamUsageChildItem.DefaultPlayback) {
                    if ($PSCmdlet.ShouldProcess($s.Camera.Name, "Set the default playback stream to $($streamUsageChildItem.Name)")) {
                        $streamUsages.StreamUsageChildItems | ForEach-Object {
                            $_.DefaultPlayback = $false
                        }
                        $streamUsageChildItem.DefaultPlayback = $PlaybackDefault
                        $dirtyStreamUsages = $true
                    }
                }

                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('UseEdge') -and $UseEdge -ne $streamUsageChildItem.UseEdge) {
                    if ($PSCmdlet.ShouldProcess($s.Camera.Name, "Enable use of edge storage on $($streamUsageChildItem.Name)")) {
                        $streamUsageChildItem.UseEdge = $UseEdge
                        $dirtyStreamUsages = $true
                    }
                }

                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('LiveDefault') -and $LiveDefault -and $LiveDefault -ne $streamUsageChildItem.LiveDefault) {
                    $liveStream = $streamUsages.StreamUsageChildItems | Where-Object LiveDefault
                    if ($PSCmdlet.ShouldProcess($s.Camera.Name, "Disabling LiveDefault on $($liveStream.Name)")) {
                        $liveStream.LiveDefault = $false
                    }

                    if ($PSCmdlet.ShouldProcess($s.Camera.Name, "Enabling LiveDefault on $($streamUsageChildItem.Name)")) {
                        $streamUsageChildItem.LiveDefault = $true
                        $dirtyStreamUsages = $true
                    }
                }

                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('LiveMode') -and $LiveMode -ne $streamUsageChildItem.LiveMode -and -not [string]::IsNullOrWhiteSpace($LiveMode)) {
                    if ($LiveMode -eq 'Never' -and (-not $streamUsageChildItem.Record -or $streamUsageChildItem.LiveDefault)) {
                        Write-Warning 'The LiveMode property can only be set to "Never" the recorded stream, and only when that stream is not used as the LiveDefault stream.'
                    } elseif ($PSCmdlet.ShouldProcess($s.Camera.Name, "Setting LiveMode on $($streamUsageChildItem.Name)")) {
                        $streamUsageChildItem.LiveMode = $LiveMode
                        $dirtyStreamUsages = $true
                    }
                }

                if ($dirtyStreamUsages -and $PSCmdlet.ShouldProcess($s.Camera.Name, "Saving StreamUsages")) {
                    $updatedItems.Add(
                        [pscustomobject]@{
                            Item         = $streamUsages
                            Parent       = $s.Camera
                            StreamConfig = $s
                        }
                    )
                }

                $streamChildItem = $deviceDriverSettings.StreamChildItems.Where( { $_.DisplayName -eq $s.Name })
                if ($Settings.Keys.Count -gt 0) {
                    $dirty = $false
                    foreach ($key in $Settings.Keys) {
                        if ($key -notin $s.Settings.Keys) {
                            Write-Warning "A setting with the key '$key' was not found for stream $($streamChildItem.DisplayName) on $($s.Camera.Name)."
                            continue
                        }

                        $currentValue = $streamChildItem.Properties.GetValue($key)
                        if ($currentValue -eq $Settings.$key) {
                            continue
                        }

                        if ($PSCmdlet.ShouldProcess($target, "Changing $key from $currentValue to $($Settings.$key)")) {
                            $streamChildItem.Properties.SetValue($key, $Settings.$key)
                            $dirty = $true
                        }
                    }
                    if ($dirty -and $PSCmdlet.ShouldProcess($target, "Save changes")) {
                        $updatedItems.Add(
                            [pscustomobject]@{
                                Item         = $deviceDriverSettings
                                Parent       = $s.Camera
                                StreamConfig = $s
                            }
                        )
                    }
                }
            }
        }
    }

    end {
        $updatedStreamConfigs = [system.collections.generic.list[object]]::new()
        foreach ($update in $updatedItems) {
            try {
                $item = $itemCache[$update.Item.Path]
                if ($null -ne $item) {
                    $item.Save()
                }
                if ($update.StreamConfig -notin $updatedStreamConfigs) {
                    $update.StreamConfig.Update()
                    $updatedStreamConfigs.Add($update.StreamConfig)
                }
            } catch [VideoOS.Platform.Proxy.ConfigApi.ValidateResultException] {
                $update.Parent.ClearChildrenCache()
                $_ | HandleValidateResultException -TargetObject $item
            } finally {
                if ($null -ne $item) {
                    $itemCache.Remove($item.Path)
                    $item = $null
                }
            }
        }
    }
}

