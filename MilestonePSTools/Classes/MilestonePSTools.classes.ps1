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

enum VmsTaskState {
    Completed
    Error
    Idle
    InProgress
    Success
    Unknown
}

class VmsTaskResult {
    [int] $Progress
    [string] $Path
    [string] $ErrorCode
    [string] $ErrorText
    [VmsTaskState] $State

    VmsTaskResult () {}

    VmsTaskResult([VideoOS.ConfigurationApi.ClientService.ConfigurationItem] $InvokeItem) {
        foreach ($p in $InvokeItem.Properties) {
            try {
                switch ($p.ValueType) {
                    'Progress' {
                        $this.($p.Key) = [int]$p.Value
                    }
                    'Tick' {
                        $this.($p.Key) = [bool]::Parse($p.Value)
                    }
                    default {
                        $this.($p.Key) = $p.Value
                    }
                }
            } catch {
                if ($p -in 'Progress', 'Path', 'ErrorCode', 'ErrorText', 'State' ) {
                    throw
                }
            }

        }
    }
}

class VmsHardwareScanResult : VmsTaskResult {
    [uri]    $HardwareAddress
    [string] $UserName
    [string] $Password
    [bool]   $MacAddressExistsGlobal
    [bool]   $MacAddressExistsLocal
    [bool]   $HardwareScanValidated
    [string] $MacAddress
    [string] $HardwareDriverPath

    # Property hidden so that this type can be cleanly exported to CSV or something
    # without adding a column with a complex object in it.
    hidden [VideoOS.Platform.ConfigurationItems.RecordingServer] $RecordingServer

    VmsHardwareScanResult() {}

    VmsHardwareScanResult([VideoOS.ConfigurationApi.ClientService.ConfigurationItem] $InvokeItem) {
        $members = ($this.GetType().GetMembers() | Where-Object MemberType -EQ 'Property').Name
        foreach ($p in $InvokeItem.Properties) {
            if ($p.Key -notin $members) {
                continue
            }
            switch ($p.ValueType) {
                'Progress' {
                    $this.($p.Key) = [int]$p.Value
                }
                'Tick' {
                    $this.($p.Key) = [bool]::Parse($p.Value)
                }
                default {
                    $this.($p.Key) = $p.Value
                }
            }
        }
    }
}

# Contains the output from the script passed to LocalJobRunner.AddJob, in addition to any errors thrown in the script if present.
class LocalJobResult {
    [object[]] $Output
    [System.Management.Automation.ErrorRecord[]] $Errors
}

# Contains the IAsyncResult object returned by PowerShell.BeginInvoke() as well as the PowerShell instance we need to
class LocalJob {
    [System.Management.Automation.PowerShell] $PowerShell
    [System.IAsyncResult] $Result
}

# Centralizes the complexity of running multiple commands/scripts at a time and receiving the results, including errors, when they complete.
class LocalJobRunner : IDisposable {
    hidden [System.Management.Automation.Runspaces.RunspacePool] $RunspacePool
    hidden [System.Collections.Generic.List[LocalJob]] $Jobs
    [timespan] $JobPollingInterval = (New-TimeSpan -Seconds 1)
    [string[]] $Modules = @()

    # Default constructor creates an underlying runspace pool with a max size matching the number of processors
    LocalJobRunner () {
        $this.Initialize($env:NUMBER_OF_PROCESSORS)
    }

    LocalJobRunner ([string[]]$Modules) {
        $this.Modules = $Modules
        $this.Initialize($env:NUMBER_OF_PROCESSORS)
    }

    # Optionally you may manually specify a max size for the underlying runspace pool.
    LocalJobRunner ([int]$MaxSize) {
        $this.Initialize($MaxSize)
    }

    hidden [void] Initialize([int]$MaxSize) {
        $this.Jobs = New-Object System.Collections.Generic.List[LocalJob]
        $iss = [initialsessionstate]::CreateDefault()
        if ($this.Modules.Count -gt 0) {
            $iss.ImportPSModule($this.Modules)
        }
        $this.RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxSize, $iss, (Get-Host))
        $this.RunspacePool.Open()
    }

    # Accepts a scriptblock and a set of parameters. A new powewershell instance will be created, attached to a runspacepool, and the results can be collected later in a call to ReceiveJobs.
    [LocalJob] AddJob([scriptblock]$scriptblock, [hashtable]$parameters) {
        $parameters = if ($null -eq $parameters) { $parameters = @{} } else { $parameters }
        $shell = [powershell]::Create()
        $shell.RunspacePool = $this.RunspacePool
        $asyncResult = $shell.AddScript($scriptblock).AddParameters($parameters).BeginInvoke()
        $job = [LocalJob]@{
            PowerShell = $shell
            Result     = $asyncResult
        }
        $this.Jobs.Add($job)
        return $job
    }

    # Returns the output from specific jobs
    [LocalJobResult[]] ReceiveJobs([LocalJob[]]$localJobs) {
        $completedJobs = $localJobs | Where-Object { $_.Result.IsCompleted }
        $completedJobs | ForEach-Object { $this.Jobs.Remove($_) }
        $results = $completedJobs | ForEach-Object {
            [LocalJobResult]@{
                Output = $_.PowerShell.EndInvoke($_.Result)
                Errors = $_.PowerShell.Streams.Error
            }

            $_.PowerShell.Dispose()
        }
        return $results
    }

    # Returns the output from any completed jobs in an object that also includes any errors if present.
    [LocalJobResult[]] ReceiveJobs() {
        return $this.ReceiveJobs($this.Jobs)
    }

    # Block until all jobs have completed. The list of jobs will be polled on an interval of JobPollingInterval, which is 1 second by default.
    [void] Wait() {
        $this.Wait($this.Jobs)
    }

    # Block until all jobs have completed. The list of jobs will be polled on an interval of JobPollingInterval, which is 1 second by default.
    [void] Wait([LocalJob[]]$jobList) {
        while ($jobList.Result.IsCompleted -contains $false) {
            Start-Sleep -Seconds $this.JobPollingInterval.TotalSeconds
        }
    }

    # Returns $true if there are any jobs available to be received using ReceiveJobs. Use to implement your own polling strategy instead of using Wait.
    [bool] HasPendingJobs() {
        return ($this.Jobs.Count -gt 0)
    }

    # Make sure to dispose of this class so that the underlying runspace pool gets disposed.
    [void] Dispose() {
        $this.Jobs.Clear()
        $this.RunspacePool.Close()
        $this.RunspacePool.Dispose()
    }
}

class VmsStreamDeviceStatus : VideoOS.Platform.SDK.Proxy.Status2.MediaStreamDeviceStatusBase {
    [string] $DeviceName
    [string] $DeviceType
    [string] $RecorderName
    [guid]   $RecorderId
    [bool]   $Motion

    VmsStreamDeviceStatus () {}
    VmsStreamDeviceStatus ([VideoOS.Platform.SDK.Proxy.Status2.MediaStreamDeviceStatusBase]$status) {
        $this.DbMoveInProgress = $status.DbMoveInProgress
        $this.DbRepairInProgress = $status.DbRepairInProgress
        if ($null -ne $status.DeviceId) {
            $this.DeviceId = $status.DeviceId
        }
        $this.Enabled = $status.Enabled
        $this.Error = $status.Error
        $this.ErrorNoConnection = $status.ErrorNoConnection
        $this.ErrorNotLicensed = $status.ErrorNotLicensed
        $this.ErrorOverflow = $status.ErrorOverflow
        $this.ErrorWritingGop = $status.ErrorWritingGop
        $this.IsChange = $status.IsChange
        $this.Recording = $status.Recording
        $this.Started = $status.Started
        if ($null -ne $status.Time) {
            $this.Time = $status.Time
        }
        if ($null -ne $status.Motion) {
            $this.Motion = $status.Motion
        }
    }
}

enum ViewItemImageQuality {
    Full = 100
    SuperHigh = 101
    High = 102
    Medium = 103
    Low = 104
}

enum ViewItemPtzMode {
    Default
    ClickToCenter
    VirtualJoystick
}

class VmsCameraViewItemProperties {
    # These represent the default XProtect Smart Client camera view item properties
    [guid]   $Id = [guid]::NewGuid()
    [guid]   $SmartClientId = [guid]::NewGuid()
    [guid]   $CameraId = [guid]::Empty
    [string] $CameraName = [string]::Empty
    [nullable[int]] $Shortcut = $null
    [guid]   $LiveStreamId = [guid]::Empty
    [ValidateRange(100, 104)]
    [int]    $ImageQuality = [ViewItemImageQuality]::Full
    [int]    $Framerate = 0
    [bool]   $MaintainImageAspectRatio = $true
    [bool]   $UseDefaultDisplaySettings = $true
    [bool]   $ShowTitleBar = $true
    [bool]   $KeepImageQualityWhenMaximized = $false
    [bool]   $UpdateOnMotionOnly = $false
    [bool]   $SoundOnMotion = $false
    [bool]   $SoundOnEvent = $false
    [int]    $SmartSearchGridWidth = 0
    [int]    $SmartSearchGridHeight = 0
    [string] $SmartSearchGridMask = [string]::Empty
    [ValidateRange(0, 2)]
    [int]    $PointAndClickMode = [ViewItemPtzMode]::Default
}

class VmsViewGroupAcl {
    [VideoOS.Platform.ConfigurationItems.Role] $Role
    [string] $Path
    [hashtable] $SecurityAttributes
}

class SecurityNamespaceTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        if ($null -eq $inputData -or $inputData.Count -eq 0) { return [guid]::Empty }
        if ($inputData -is [guid] -or ($inputData -is [system.collections.ienumerable] -and $inputData[0] -is [guid])) {
            return $inputData
        }
        if ($inputData.SecurityNamespace) {
            $inputData = $inputData.SecurityNamespace
        }
        if ($inputData -is [string] -or ($inputData -is [system.collections.ienumerable] -and $inputData[0] -is [string])) {
            $securityNamespaces = Get-SecurityNamespaceValues
            $result = [string[]]@()
            foreach ($value in $inputData) {
                $id = [guid]::Empty
                if (-not [guid]::TryParse($value, [ref]$id)) {
                    try {
                        $id = if ($securityNamespaces.SecurityNamespacesByName.ContainsKey($value)) { $securityNamespaces.SecurityNamespacesByName[$value] } else { $value }
                    } catch {
                        $id = $value
                    }
                    $result += $id
                } else {
                    $result += $id
                }
            }
            if ($result.Count -eq 0) {
                throw 'No matching SecurityNamespace(s) found.'
            }
            if ($inputData -is [string]) {
                return $result[0]
            }
            return $result
        }
        throw "Unexpected type '$($inputData.GetType().FullName)'"
    }

    [string] ToString() {
        return '[SecurityNamespaceTransformAttribute()]'
    }
}

class TimeProfileNameTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        if ($inputData -is [VideoOS.Platform.ConfigurationItems.TimeProfile] -or ($inputData -is [system.collections.ienumerable] -and $inputData[0] -is [VideoOS.Platform.ConfigurationItems.TimeProfile])) {
            return $inputData
        }
        try {
            if ($inputData.TimeProfile) {
                $inputData = $inputData.TimeProfile
            }
            if ($inputData -is [string] -or ($inputData -is [system.collections.ienumerable] -and $inputData[0] -is [string])) {
                $items = $inputData | ForEach-Object {
                    if ($_ -eq 'Always') {
                        @(
                            $always = [VideoOS.ConfigurationApi.ClientService.ConfigurationItem]@{
                                DisplayName  = 'Always'
                                ItemCategory = 'Item'
                                ItemType     = 'TimeProfile'
                                Path         = 'TimeProfile[11111111-1111-1111-1111-111111111111]'
                                ParentPath   = '/TimeProfileFolder'
                            }
                            [VideoOS.Platform.ConfigurationItems.TimeProfile]::new((Get-VmsManagementServer).ServerId, $always)
                        )
                    } elseif ($_ -eq 'Default') {
                        @(
                            $default = [VideoOS.ConfigurationApi.ClientService.ConfigurationItem]@{
                                DisplayName  = 'Default'
                                ItemCategory = 'Item'
                                ItemType     = 'TimeProfile'
                                Path         = 'TimeProfile[00000000-0000-0000-0000-000000000000]'
                                ParentPath   = '/TimeProfileFolder'
                            }
                            [VideoOS.Platform.ConfigurationItems.TimeProfile]::new((Get-VmsManagementServer).ServerId, $default)
                        )
                    } else {
                        (Get-VmsManagementServer).TimeProfileFolder.TimeProfiles | Where-Object Name -EQ $_
                    }
                }
                if ($items.Count -eq 0) {
                    throw 'No matching TimeProfile(s) found.'
                }
                if ($inputData -is [string]) {
                    return $items[0]
                } else {
                    return $items
                }
            } else {
                throw "Unexpected type '$($inputData.GetType().FullName)'"
            }
        } catch {
            throw $_.Exception
        }
    }

    [string] ToString() {
        return '[TimeProfileNameTransformAttribute()]'
    }
}

class StorageNameTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        if ($inputData -is [VideoOS.Platform.ConfigurationItems.Storage] -or ($inputData -is [system.collections.ienumerable] -and $inputData[0] -is [VideoOS.Platform.ConfigurationItems.Storage])) {
            return $inputData
        }
        try {
            if ($inputData.Storage) {
                $inputData = $inputData.Storage
            }
            if ($inputData -is [string] -or ($inputData -is [system.collections.ienumerable] -and $inputData[0] -is [string])) {
                $items = $inputData | ForEach-Object {
                    Get-VmsRecordingServer | Get-VmsStorage | Where-Object Name -EQ $_
                }
                if ($items.Count -eq 0) {
                    throw 'No matching storage(s) found.'
                }
                return $items
            } else {
                throw "Unexpected type '$($inputData.GetType().FullName)'"
            }
        } catch {
            throw $_.Exception
        }
    }

    [string] ToString() {
        return '[StorageNameTransformAttribute()]'
    }
}

class BooleanTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        if ($inputData -is [bool]) {
            return $inputData
        } elseif ($inputData -is [string]) {
            return [bool]::Parse($inputData)
        } elseif ($inputData -is [int]) {
            return [bool]$inputData
        } elseif ($inputData -is [VideoOS.ConfigurationApi.ClientService.EnablePropertyInfo]) {
            return $inputData.Enabled
        }
        throw "Unexpected type '$($inputData.GetType().FullName)'"
    }

    [string] ToString() {
        return '[BooleanTransformAttribute()]'
    }
}

class ReplaceHardwareTaskInfo {
    [string]
    $HardwareName

    [videoos.platform.proxy.ConfigApi.ConfigurationItemPath]
    $HardwarePath

    [videoos.platform.proxy.ConfigApi.ConfigurationItemPath]
    $RecorderPath

    [VideoOS.ConfigurationApi.ClientService.ConfigurationItem]
    $Task
}

class HardwareDriverTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        $driversById = @{}
        $driversByName = @{}
        $rec = $null
        return ($inputData | ForEach-Object {
                $obj = $_
                if ($obj -is [VideoOS.Platform.ConfigurationItems.HardwareDriver]) {
                    $obj
                    return
                }

                if ($driversById.Count -eq 0) {
                    $rec = Get-VmsRecordingServer | Select-Object -First 1
                    $rec | Get-VmsHardwareDriver | ForEach-Object {
                        $driversById[$_.Number] = $_
                        $driversByName[$_.Name] = $_
                    }
                }
                switch ($obj.GetType()) {
                ([int]) {
                        if (-not $driversById.ContainsKey($obj)) {
                            throw [VideoOS.Platform.PathNotFoundMIPException]::new('Hardware driver with ID {0} not found on recording server "{1}".' -f $obj, $_)
                        }
                        $driversById[$obj]
                    }

                ([string]) {
                        $driversByName[$obj]
                    }

                    default {
                        throw [System.InvalidOperationException]::new("Unable to transform object of type $($_.FullName) to type VideoOS.Platform.ConfigurationItems.HardwareDriver")
                    }
                }
            })
    }

    [string] ToString() {
        return '[HardwareDriverTransformAttribute()]'
    }
}

class SecureStringTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        return ($inputData | ForEach-Object {
                $obj = $_
                if ($obj -as [securestring]) {
                    $obj
                    return
                }
                if ($null -eq $obj -or $obj -isnot [string]) {
                    throw 'Expected object of type SecureString or String.'
                }
                $obj | ConvertTo-SecureString -AsPlainText -Force
            })
    }

    [string] ToString() {
        return '[SecureStringTransformAttribute()]'
    }
}

class BoolTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        return ($inputData | ForEach-Object {
                $obj = $_
                if ($obj -is [bool]) {
                    $obj
                    return
                }
                if ($null -eq $obj -or -not [bool]::TryParse($obj, [ref]$obj)) {
                    throw "Failed to parse '$obj' as [bool]"
                }
                $obj
            })
    }

    [string] ToString() {
        return '[BoolTransformAttribute()]'
    }
}

class ClaimTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        if ($inputData -is [VideoOS.Platform.ConfigurationItems.ClaimChildItem] -or ($inputData -is [system.collections.ienumerable] -and $inputData[0] -is [VideoOS.Platform.ConfigurationItems.ClaimChildItem])) {
            return $inputData
        }
        try {
            if ($inputData.Claim) {
                $inputData = $inputData.Claim
            }
            if ($inputData -is [string] -or ($inputData -is [system.collections.ienumerable] -and $inputData[0] -is [string])) {
                $items = Get-VmsLoginProvider | Where-Object { $_.Name -eq $inputData -or $_.Id -eq $inputData }
                if ($inputData -is [string]) {
                    return $items[0]
                }
                return $items
            } else {
                throw "Unexpected type '$($inputData.GetType().FullName)'"
            }
        } catch {
            throw $_.Exception
        }
    }

    [string] ToString() {
        return '[LoginProviderTransformAttribute()]'
    }
}

class PropertyCollectionTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        if ($inputData -is [System.Collections.IDictionary]) {
            return $inputData
        }
        try {
            $hashtable = @{}
            $inputData.GetEnumerator() | ForEach-Object {
                if ($null -eq ($_ | Get-Member -Name Key) -or $null -eq ($_ | Get-Member -Name Value)) {
                    throw 'Key and Value properties most both be present in a property collection.'
                }
                $hashtable[$_.Key] = $_.Value
            }
            return $hashtable
        } catch {
            throw $_.Exception
        }
    }

    [string] ToString() {
        return '[PropertyCollectionTransformAttribute()]'
    }
}

class RuleNameTransformAttribute : System.Management.Automation.ArgumentTransformationAttribute {
    [object] Transform([System.Management.Automation.EngineIntrinsics]$engineIntrinsics, [object] $inputData) {
        $expectedType = [VideoOS.ConfigurationApi.ClientService.ConfigurationItem]
        $itemType = 'Rule'

        if ($inputData -is $expectedType -or ($inputData -is [system.collections.ienumerable] -and $inputData[0] -is $expectedType)) {
            return $inputData
        }
        try {
            $items = $inputData | ForEach-Object {
                $stringValue = $_.ToString() -replace "^$ItemType\[(.+)\](?:/.+)?", '$1'
                $id = [guid]::Empty
                if ([guid]::TryParse($stringValue, [ref]$id)) {
                    Get-VmsRule | Where-Object Path -Match $stringValue
                } else {
                    Get-VmsRule | Where-Object DisplayName -EQ $stringValue
                }
            }
            if ($null -eq $items) {
                throw ([System.Management.Automation.ItemNotFoundException]::new("$itemType '$($inputData)' not found."))
            }
            return $items
        } catch {
            throw $_.Exception
        }
    }

    [string] ToString() {
        return '[RuleNameTransformAttribute()]'
    }
}
