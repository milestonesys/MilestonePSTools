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

function Get-VmsCameraReport {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    param (
        [Parameter()]
        [ArgumentCompleter([MipItemNameCompleter[RecordingServer]])]
        [MipItemTransformation([RecordingServer])]
        [RecordingServer[]]
        $RecordingServer,

        [Parameter()]
        [switch]
        $IncludePlainTextPasswords,

        [Parameter()]
        [switch]
        $IncludeRetentionInfo,

        [Parameter()]
        [switch]
        $IncludeRecordingStats,

        [Parameter()]
        [switch]
        $IncludeSnapshots,

        [Parameter()]
        [ValidateRange(0, [int]::MaxValue)]
        [int]
        $SnapshotTimeoutMS = 10000,

        [Parameter()]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $SnapshotHeight = 300,

        [Parameter()]
        [ValidateSet('All', 'Disabled', 'Enabled')]
        [string]
        $EnableFilter = 'Enabled'
    )

    begin {
        Assert-VmsRequirementsMet -ErrorAction Stop
        try {
            $ms = Get-VmsManagementServer -ErrorAction Stop
            for ($attempt = 1; $attempt -le 2; $attempt++) {
                try {
                    $supportsFillChildren = [version]$ms.Version -ge '20.2'
                    $scs = Get-IServerCommandService -ErrorAction Stop
                    $config = $scs.GetConfiguration((Get-VmsToken))
                    $recorderCameraMap = @{}
                    $config.Recorders | ForEach-Object {
                        $deviceList = New-Object System.Collections.Generic.List[guid]
                        $_.Cameras.DeviceId | ForEach-Object { if ($_) { $deviceList.Add($_) } }
                        $recorderCameraMap.($_.RecorderId) = $deviceList
                    }
                    break
                } catch {
                    if ($attempt -ge 2) {
                        throw
                    }
                    # Typically if an error is thrown here, it's on $scs.GetConfiguration because the
                    # IServerCommandService WCF channel is cached and reused, and might be timed out.
                    # The Select-VmsSite cmdlet has a side effect of flushing all cached WCF channels.
                    Get-VmsSite | Select-VmsSite
                }
            }
            $roleMemberships = (Get-LoginSettings | Where-Object Guid -EQ (Get-VmsSite).FQID.ObjectId).GroupMembership
            $isAdmin = (Get-VmsRole -RoleType Adminstrative).Id -in $roleMemberships
            $manifestPath = Join-Path $PSCmdlet.MyInvocation.MyCommand.Module.ModuleBase 'MilestonePSTools.psd1'
            $jobRunner = [LocalJobRunner]::new($manifestPath)
            $jobRunner.JobPollingInterval = [timespan]::FromMilliseconds(500)
        } catch {
            throw
        }
    }

    process {
        try {
            if ($IncludePlainTextPasswords -and -not $isAdmin) {
                Write-Warning $script:Messages.MustBeAdminToReadPasswords
            }
            if (-not $RecordingServer) {
                Write-Verbose $script:Messages.ListingAllRecorders
                $RecordingServer = Get-VmsRecordingServer
            }
            $cache = @{
                DeviceState    = @{}
                PlaybackInfo   = @{}
                Snapshots      = @{}
                Passwords      = @{}
                RecordingStats = @{}
            }

            $ids = @()
            $RecordingServer | ForEach-Object {
                if ($null -ne $recorderCameraMap[[guid]$_.Id] -and $recorderCameraMap[[guid]$_.Id].Count -gt 0) {
                    $ids += $recorderCameraMap[[guid]$_.Id]
                }
            }

            Write-Verbose $script:Messages.CallingGetItemState
            Get-ItemState -CamerasOnly -ErrorAction Ignore | ForEach-Object {
                $cache.DeviceState[$_.FQID.ObjectId] = @{
                    ItemState = $_.State
                }
            }

            Write-Verbose $script:Messages.StartingFillChildrenThreadJob
            $fillChildrenJobs = $RecordingServer | ForEach-Object {
                $jobRunner.AddJob(
                    {
                        param([bool]$supportsFillChildren, [object]$recorder, [string]$EnableFilter, [bool]$getPasswords, [hashtable]$cache)

                        $manualMethod = {
                            param([object]$recorder)
                            $null = $recorder.HardwareDriverFolder.HardwareDrivers
                            $null = $recorder.StorageFolder.Storages.ArchiveStorageFolder.ArchiveStorages
                            $null = $recorder.HardwareFolder.Hardwares.HardwareDriverSettingsFolder.HardwareDriverSettings
                            $null = $recorder.HardwareFolder.Hardwares.CameraFolder.Cameras.StreamFolder.Streams
                            $null = $recorder.HardwareFolder.Hardwares.CameraFolder.Cameras.DeviceDriverSettingsFolder.DeviceDriverSettings
                        }
                        if ($supportsFillChildren) {
                            try {
                                $itemTypes = 'Hardware', 'HardwareDriverFolder', 'HardwareDriver', 'HardwareDriverSettingsFolder', 'HardwareDriverSettings', 'StorageFolder', 'Storage', 'StorageInformation', 'ArchiveStorageFolder', 'ArchiveStorage', 'CameraFolder', 'Camera', 'DeviceDriverSettingsFolder', 'DeviceDriverSettings', 'MotionDetectionFolder', 'MotionDetection', 'StreamFolder', 'Stream', 'StreamSettings', 'StreamDefinition', 'ClientSettings'
                                $alwaysIncludedItemTypes = @('MotionDetection', 'HardwareDriver', 'HardwareDriverSettings', 'Hardware', 'Storage', 'ArchiveStorage', 'DeviceDriverSettings')
                                $supportsPrivacyMask = (Get-IServerCommandService).GetConfiguration((Get-VmsToken)).ServerOptions | Where-Object Key -EQ 'PrivacyMask' | Select-Object -ExpandProperty Value
                                if ($supportsPrivacyMask -eq 'True') {
                                    $itemTypes += 'PrivacyProtectionFolder' , 'PrivacyProtection'
                                    $alwaysIncludedItemTypes += 'PrivacyProtectionFolder', 'PrivacyProtection'
                                }
                                $itemFilters = $itemTypes | ForEach-Object {
                                    $enableFilterSelection = if ($_ -in $alwaysIncludedItemTypes) { 'All' } else { $EnableFilter }
                                    [VideoOS.ConfigurationApi.ClientService.ItemFilter]@{
                                        ItemType        = $_
                                        EnableFilter    = $enableFilterSelection
                                        PropertyFilters = @()
                                    }
                                }
                                $recorder.FillChildren($itemTypes, $itemFilters)

                                # TODO: Remove this after TFS 447559 is addressed. The StreamFolder.Streams collection is empty after using FillChildren
                                # So this entire foreach block is only necessary to flush the children of StreamFolder and force another query for every
                                # camera so we can fill the collection up in this background task before enumerating over everything at the end.
                                foreach ($hw in $recorder.hardwarefolder.hardwares) {
                                    if ($getPasswords) {
                                        $password = $hw.ReadPasswordHardware().GetProperty('Password')
                                        $cache.Passwords[[guid]$hw.Id] = $password
                                    }
                                    foreach ($cam in $hw.camerafolder.cameras) {
                                        try {
                                            if ($null -ne $cam.StreamFolder -and $cam.StreamFolder.Streams.Count -eq 0) {
                                                $cam.StreamFolder.ClearChildrenCache()
                                                $null = $cam.StreamFolder.Streams
                                            }
                                        } catch {
                                            Write-Error $_
                                        }
                                    }
                                }
                            } catch {
                                Write-Error $_
                                $manualMethod.Invoke($recorder)
                            }
                        } else {
                            $manualMethod.Invoke($recorder)
                        }
                    },
                    @{ SupportsFillChildren = $supportsFillChildren; recorder = $_; EnableFilter = $EnableFilter; getPasswords = ($isAdmin -and $IncludePlainTextPasswords); cache = $cache }
                )
            }

            # Kick off snapshots early if requested. Pick up results at the end.
            $snapshotsById = @{}
            if ($IncludeSnapshots) {
                Write-Verbose 'Starting Get-Snapshot threadjob'
                $snapshotScriptBlock = {
                    param([guid[]]$ids, [int]$snapshotHeight, [hashtable]$snapshotsById, [hashtable]$cache, [int]$liveTimeoutMS)
                    foreach ($id in $ids) {
                        $itemState = $cache.DeviceState[$id].ItemState
                        if (-not [string]::IsNullOrWhiteSpace($itemState) -and $itemState -ne 'Responding') {
                            # Do not attempt to get a live image if the event server says the camera is not responding. Saves time.
                            continue
                        }
                        $snapshot = Get-Snapshot -CameraId $id -Live -Quality 100 -LiveTimeoutMS $liveTimeoutMS
                        if ($null -ne $snapshot) {
                            $image = $snapshot | ConvertFrom-Snapshot | Resize-Image -Height $snapshotHeight -DisposeSource
                            $snapshotsById[$id] = $image
                        }
                    }
                }
                $snapshotsJob = $jobRunner.AddJob($snapshotScriptBlock, @{ids = $ids; snapshotHeight = $SnapshotHeight; snapshotsById = $snapshotsById; cache = $cache; liveTimeoutMS = $SnapshotTimeoutMS })
            }

            if ($IncludeRetentionInfo) {
                Write-Verbose 'Starting Get-PlaybackInfo threadjob'
                $playbackInfoScriptblock = {
                    param(
                        [guid]$id,
                        [hashtable]$cache
                    )

                    $info = Get-PlaybackInfo -Path "Camera[$id]"
                    if ($null -ne $info) {
                        $cache.PlaybackInfo[$id] = $info
                    }
                }
                $playbackInfoJobs = $ids | ForEach-Object {
                    if ($null -ne $_) {
                        $jobRunner.AddJob($playbackInfoScriptblock, @{ id = $_; cache = $cache } )
                    }
                }
            }

            if ($IncludeRecordingStats) {
                Write-Verbose 'Starting recording stats threadjob'
                $recordingStatsScript = {
                    param(
                        [guid]$Id,
                        [datetime]$StartTime,
                        [datetime]$EndTime,
                        [string]$SequenceType
                    )

                    $sequences = Get-SequenceData -Path "Camera[$Id]" -SequenceType $SequenceType -StartTime $StartTime -EndTime $EndTime -CropToTimeSpan
                    $recordedMinutes = $sequences | ForEach-Object {
                        ($_.EventSequence.EndDateTime - $_.EventSequence.StartDateTime).TotalMinutes
                    } | Measure-Object -Sum | Select-Object -ExpandProperty Sum
                    [pscustomobject]@{
                        DeviceId        = $Id
                        StartTime       = $StartTime
                        EndTime         = $EndTime
                        SequenceCount   = $sequences.Count
                        TimeRecorded    = [timespan]::FromMinutes($recordedMinutes)
                        PercentRecorded = [math]::Round(($recordedMinutes / ($EndTime - $StartTime).TotalMinutes * 100), 1)
                    }
                }
                $endTime = Get-Date
                $startTime = $endTime.AddDays(-7)
                $recordingStatsJobs = $ids | ForEach-Object {
                    $jobRunner.AddJob($recordingStatsScript, @{Id = $_; StartTime = $startTime; EndTime = $endTime; SequenceType = 'RecordingSequence' })
                }
            }

            # Get VideoDeviceStatistics for all Recording Servers in the report
            Write-Verbose 'Starting GetVideoDeviceStatistics threadjob'
            $videoDeviceStatsScriptBlock = {
                param(
                    [VideoOS.Platform.SDK.Proxy.Status2.RecorderStatusService2]$svc,
                    [guid[]]$ids
                )
                $svc.GetVideoDeviceStatistics((Get-VmsToken), $ids)
            }
            $videoDeviceStatsJobs = $RecordingServer | ForEach-Object {
                $svc = $_ | Get-RecorderStatusService2
                if ($null -ne $svc) {
                    $jobRunner.AddJob($videoDeviceStatsScriptBlock, @{ svc = $svc; ids = $recorderCameraMap[[guid]$_.Id] })
                }
            }

            # Get Current Device Status for everything in the report
            Write-Verbose 'Starting GetCurrentDeviceStatus threadjob'
            $currentDeviceStatsJobsScriptBlock = {
                param(
                    [VideoOS.Platform.SDK.Proxy.Status2.RecorderStatusService2]$svc,
                    [guid[]]$ids
                )
                $svc.GetCurrentDeviceStatus((Get-VmsToken), $ids)
            }
            $currentDeviceStatsJobs = $RecordingServer | Where-Object { ($recorderCameraMap[[guid]$_.Id]).Count } | ForEach-Object {
                $svc = $_ | Get-RecorderStatusService2
                $jobRunner.AddJob($currentDeviceStatsJobsScriptBlock, @{svc = $svc; ids = $recorderCameraMap[[guid]$_.Id] })
            }

            Write-Verbose 'Receiving results of FillChildren threadjob'
            $jobRunner.Wait($fillChildrenJobs)
            $fillChildrenResults = $jobRunner.ReceiveJobs($fillChildrenJobs)
            foreach ($e in $fillChildrenResults.Errors) {
                Write-Error $e
            }

            if ($IncludeRetentionInfo) {
                Write-Verbose 'Receiving results of Get-PlaybackInfo threadjob'
                $jobRunner.Wait($playbackInfoJobs)
                $playbackInfoResult = $jobRunner.ReceiveJobs($playbackInfoJobs)
                foreach ($e in $playbackInfoResult.Errors) {
                    Write-Error $e
                }
            }

            if ($IncludeRecordingStats) {
                Write-Verbose 'Receiving results of recording stats threadjob'
                $jobRunner.Wait($recordingStatsJobs)
                foreach ($job in $jobRunner.ReceiveJobs($recordingStatsJobs)) {
                    if ($job.Output.DeviceId) {
                        $cache.RecordingStats[$job.Output.DeviceId] = $job.Output
                    }
                    foreach ($e in $job.Errors) {
                        Write-Error $e
                    }
                }
            }

            Write-Verbose 'Receiving results of GetVideoDeviceStatistics threadjobs'
            $jobRunner.Wait($videoDeviceStatsJobs)
            foreach ($job in $jobRunner.ReceiveJobs($videoDeviceStatsJobs)) {
                foreach ($result in $job.Output) {
                    if (-not $cache.DeviceState.ContainsKey($result.DeviceId)) {
                        $cache.DeviceState[$result.DeviceId] = @{}
                    }
                    $cache.DeviceState[$result.DeviceId].UsedSpaceInBytes = $result.UsedSpaceInBytes
                    $cache.DeviceState[$result.DeviceId].VideoStreamStatisticsArray = $result.VideoStreamStatisticsArray
                }
                foreach ($e in $job.Errors) {
                    Write-Error $e
                }
            }

            Write-Verbose 'Receiving results of GetCurrentDeviceStatus threadjobs'
            $jobRunner.Wait($currentDeviceStatsJobs)
            $currentDeviceStatsResult = $jobRunner.ReceiveJobs($currentDeviceStatsJobs)
            $currentDeviceStatsResult.Output | ForEach-Object {
                foreach ($row in $_.CameraDeviceStatusArray) {
                    if (-not $cache.DeviceState.ContainsKey($row.DeviceId)) {
                        $cache.DeviceState[$row.DeviceId] = @{}
                    }
                    $cache.DeviceState[$row.DeviceId].Status = $row
                }
            }
            foreach ($e in $currentDeviceStatsResult.Errors) {
                Write-Error $e
            }

            if ($null -ne $snapshotsJob) {
                Write-Verbose 'Receiving results of Get-Snapshot threadjob'
                $jobRunner.Wait($snapshotsJob)
                $snapshotsResult = $jobRunner.ReceiveJobs($snapshotsJob)
                $cache.Snapshots = $snapshotsById
                foreach ($e in $snapshotsResult.Errors) {
                    Write-Error $e
                }
            }

            foreach ($rec in $RecordingServer) {
                foreach ($hw in $rec.HardwareFolder.Hardwares | Where-Object { if ($EnableFilter -eq 'All') { $true } else { $_.Enabled } }) {
                    try {
                        $hwSettings = ConvertFrom-ConfigurationApiProperties -Properties $hw.HardwareDriverSettingsFolder.HardwareDriverSettings[0].HardwareDriverSettingsChildItems[0].Properties -UseDisplayNames
                        $driver = $rec.HardwareDriverFolder.HardwareDrivers | Where-Object Path -EQ $hw.HardwareDriverPath
                        foreach ($cam in $hw.CameraFolder.Cameras | Where-Object { if ($EnableFilter -eq 'All') { $true } elseif ($EnableFilter -eq 'Enabled') { $_.Enabled -and $hw.Enabled } else { !$_.Enabled -or !$hw.Enabled } }) {
                            $id = [guid]$cam.Id
                            $state = $cache.DeviceState[$id]
                            $storage = $rec.StorageFolder.Storages | Where-Object Path -EQ $cam.RecordingStorage
                            $motion = $cam.MotionDetectionFolder.MotionDetections[0]
                            if ($cam.StreamFolder.Streams.Count -gt 0) {
                                $liveStreamSettings = $cam | Get-VmsCameraStream -LiveDefault -ErrorAction Ignore
                                $liveStreamStats = $state.VideoStreamStatisticsArray | Where-Object StreamId -EQ $liveStreamSettings.StreamReferenceId
                                $recordedStreamSettings = $cam | Get-VmsCameraStream -Recorded -ErrorAction Ignore
                                $recordedStreamStats = $state.VideoStreamStatisticsArray | Where-Object StreamId -EQ $recordedStreamSettings.StreamReferenceId
                            } else {
                                Write-Warning "Live & recorded stream properties unavailable for $($cam.Name) as the camera does not support multi-streaming."
                            }
                            $obj = [ordered]@{
                                Name                         = $cam.Name
                                Channel                      = $cam.Channel
                                Enabled                      = $cam.Enabled -and $hw.Enabled
                                ShortName                    = $cam.ShortName
                                Shortcut                     = $cam.ClientSettingsFolder.ClientSettings.Shortcut
                                State                        = $state.ItemState
                                LastModified                 = $cam.LastModified
                                Id                           = $cam.Id
                                IsStarted                    = $state.Status.Started
                                IsMotionDetected             = $state.Status.Motion
                                IsRecording                  = $state.Status.Recording
                                IsInOverflow                 = $state.Status.ErrorOverflow
                                IsInDbRepair                 = $state.Status.DbRepairInProgress
                                ErrorWritingGOP              = $state.Status.ErrorWritingGop
                                ErrorNotLicensed             = $state.Status.ErrorNotLicensed
                                ErrorNoConnection            = $state.Status.ErrorNoConnection
                                StatusTime                   = $state.Status.Time
                                GpsCoordinates               = $cam.GisPoint | ConvertFrom-GisPoint

                                HardwareName                 = $hw.Name
                                HardwareId                   = $hw.Id
                                Model                        = $hw.Model
                                Address                      = $hw.Address
                                Username                     = $hw.UserName
                                Password                     = if ($cache.Passwords.ContainsKey([guid]$hw.Id)) { $cache.Passwords[[guid]$hw.Id] } else { 'NotIncluded' }
                                HTTPSEnabled                 = $hwSettings.HTTPSEnabled -eq 'yes'
                                MAC                          = $hwSettings.MacAddress
                                Firmware                     = $hwSettings.FirmwareVersion

                                DriverFamily                 = $driver.GroupName
                                Driver                       = $driver.Name
                                DriverNumber                 = $driver.Number
                                DriverVersion                = $driver.DriverVersion
                                DriverRevision               = $driver.DriverRevision

                                RecorderName                 = $rec.Name
                                RecorderUri                  = $rec.ActiveWebServerUri, $rec.WebServerUri | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1
                                RecorderId                   = $rec.Id

                                LiveStream                   = $liveStreamSettings.Name
                                LiveStreamDescription        = $liveStreamSettings.DisplayName
                                LiveStreamMode               = $liveStreamSettings.LiveMode
                                ConfiguredLiveResolution     = $liveStreamSettings.Settings.Resolution, $liveStreamSettings.Settings.StreamProperty | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1
                                ConfiguredLiveCodec          = $liveStreamSettings.Settings.Codec
                                ConfiguredLiveFPS            = $liveStreamSettings.Settings.FPS, $liveStreamSettings.Settings.FrameRate | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1
                                CurrentLiveResolution        = if ($null -eq $liveStreamStats) { 'Unavailable' } else { '{0}x{1}' -f $liveStreamStats.ImageResolution.Width, $liveStreamStats.ImageResolution.Height }
                                CurrentLiveCodec             = if ($null -eq $liveStreamStats) { 'Unavailable' } else { $liveStreamStats.VideoFormat }
                                CurrentLiveFPS               = if ($null -eq $liveStreamStats) { 'Unavailable' } else { $liveStreamStats.FPS -as [int] }
                                CurrentLiveBitrate           = if ($null -eq $liveStreamStats) { 'Unavailable' } else { (($liveStreamStats.BPS -as [int]) / 1MB).ToString('N1') }

                                RecordedStream               = $recordedStreamSettings.Name
                                RecordedStreamDescription    = $recordedStreamSettings.DisplayName
                                RecordedStreamMode           = $recordedStreamSettings.LiveMode
                                ConfiguredRecordedResolution = $recordedStreamSettings.Settings.Resolution, $recordedStreamSettings.Settings.StreamProperty | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1
                                ConfiguredRecordedCodec      = $recordedStreamSettings.Settings.Codec
                                ConfiguredRecordedFPS        = $recordedStreamSettings.Settings.FPS, $recordedStreamSettings.Settings.FrameRate | Where-Object { ![string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1
                                CurrentRecordedResolution    = if ($null -eq $recordedStreamStats) { 'Unavailable' } else { '{0}x{1}' -f $recordedStreamStats.ImageResolution.Width, $recordedStreamStats.ImageResolution.Height }
                                CurrentRecordedCodec         = if ($null -eq $recordedStreamStats) { 'Unavailable' } else { $recordedStreamStats.VideoFormat }
                                CurrentRecordedFPS           = if ($null -eq $recordedStreamStats) { 'Unavailable' } else { $recordedStreamStats.FPS -as [int] }
                                CurrentRecordedBitrate       = if ($null -eq $recordedStreamStats) { 'Unavailable' } else { (($recordedStreamStats.BPS -as [int]) / 1MB).ToString('N1') }

                                RecordingEnabled             = $cam.RecordingEnabled
                                RecordKeyframesOnly          = $cam.RecordKeyframesOnly
                                RecordOnRelatedDevices       = $cam.RecordOnRelatedDevices
                                PrebufferEnabled             = $cam.PrebufferEnabled
                                PrebufferSeconds             = $cam.PrebufferSeconds
                                PrebufferInMemory            = $cam.PrebufferInMemory

                                RecordingStorageName         = $storage.Name
                                RecordingPath                = [io.path]::Combine($storage.DiskPath, $storage.Id)
                                ExpectedRetentionDays        = ($storage | Get-VmsStorageRetention).TotalDays
                                PercentRecordedOneWeek       = if ($IncludeRecordingStats) { $cache.RecordingStats[$id].PercentRecorded -as [double] } else { 'NotIncluded' }

                                MediaDatabaseBegin           = if ($null -eq $cache.PlaybackInfo[$id].Begin) { if ($IncludeRetentionInfo) { 'Unavailable' } else { 'NotIncluded' } } else { $cache.PlaybackInfo[$id].Begin }
                                MediaDatabaseEnd             = if ($null -eq $cache.PlaybackInfo[$id].End) { if ($IncludeRetentionInfo) { 'Unavailable' } else { 'NotIncluded' } } else { $cache.PlaybackInfo[$id].End }
                                UsedSpaceInGB                = if ($null -eq $state.UsedSpaceInBytes) { 'Unavailable' } else { ($state.UsedSpaceInBytes / 1GB).ToString('N2') }

                            }
                            if ($IncludeRetentionInfo) {
                                $obj.ActualRetentionDays  = ($cache.PlaybackInfo[$id].End - $cache.PlaybackInfo[$id].Begin).TotalDays
                                $obj.MeetsRetentionPolicy = $obj.ActualRetentionDays -gt $obj.ExpectedRetentionDays
                                $obj.MediaDatabaseBegin   = $cache.PlaybackInfo[$id].Begin
                                $obj.MediaDatabaseEnd     = $cache.PlaybackInfo[$id].End
                            }

                            $obj.MotionEnabled = $motion.Enabled
                            $obj.MotionKeyframesOnly = $motion.KeyframesOnly
                            $obj.MotionProcessTime = $motion.ProcessTime
                            $obj.MotionManualSensitivityEnabled = $motion.ManualSensitivityEnabled
                            $obj.MotionManualSensitivity = [int]($motion.ManualSensitivity / 3)
                            $obj.MotionThreshold = $motion.Threshold
                            $obj.MotionMetadataEnabled = $motion.GenerateMotionMetadata
                            $obj.MotionExcludeRegions = $motion.UseExcludeRegions
                            $obj.MotionHardwareAccelerationMode = $motion.HardwareAccelerationMode

                            $obj.PrivacyMaskEnabled = ($cam.PrivacyProtectionFolder.PrivacyProtections | Select-Object -First 1).Enabled -eq $true

                            if ($IncludeSnapshots) {
                                $obj.Snapshot = $cache.Snapshots[$id]
                            }
                            Write-Output ([pscustomobject]$obj)
                        }
                    } catch {
                        Write-Error $_
                    }
                }
            }
        } finally {
            if ($jobRunner) {
                $jobRunner.Dispose()
            }
        }
    }
}
