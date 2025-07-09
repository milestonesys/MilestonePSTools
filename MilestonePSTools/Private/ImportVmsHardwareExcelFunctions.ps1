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

$script:TruthyFalsey = [regex]::new('^\s*(true|yes|yep|affirmative|1|false|no|nope|negative|0)\s*$', [RegexOptions]::IgnoreCase)
$script:Truthy = [regex]::new('^\s*(true|yes|yep|affirmative|1)\s*$', [RegexOptions]::IgnoreCase)

function Show-FileDialog {
    [CmdletBinding(DefaultParameterSetName = 'OpenFile')]
    param (
        [Parameter(ParameterSetName = 'OpenFile')]
        [switch]
        $OpenFile,

        [Parameter(Mandatory, ParameterSetName = 'SaveFile')]
        [switch]
        $SaveFile
    )

    process {
        $params = @{
            Title            = 'ImportVmsHardwareExcel'
            Filter           = 'Excel files (*.xlsx)|*.xlsx|All files (*.*)|*.*'
            DefaultExt       = '.xlsx'
            RestoreDirectory = $true
            AddExtension     = $true
        }
        switch ($PSCmdlet.ParameterSetName) {
            'OpenFile' {
                $dialog = [OpenFileDialog]$params
            }
            'SaveFile' {
                $params.FileName = 'Hardware_{0}.xlsx' -f (Get-Date -Format 'yyyy-MM-dd_HH-mm-ss')
                $dialog = [SaveFileDialog]$params
            }
            Default {
                throw "ParameterSetName '$_' not implemented."
            }
        }

        try {
            $form = [form]@{
                TopMost = $true
            }
            if ($dialog.ShowDialog($form) -eq 'OK') {
                $dialog.FileName
            } else {
                throw "$($PSCmdlet.ParameterSetName) aborted."
            }
        } finally {
            if ($dialog) {
                $dialog.Dispose()
            }
            if ($form) {
                $form.Dispose()
            }
        }
    }
}

function Resolve-Path2 {
    <#
    .SYNOPSIS
    Resolves paths like the PowerShell-native `Resolve-Path` cmdlet, even for
    paths that don't exist yet.

    .NOTES
    Inspired by a [blog post](http://devhawk.net/blog/2010/1/22/fixing-powershells-busted-resolve-path-cmdlet)
    by DevHawk, aka Harry Pierson, linked to by joshuapoehls on [stackoverflow.com](https://stackoverflow.com/a/12605755/3736007).
    #>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0, ParameterSetName = 'Path')]
        [SupportsWildcards()]
        [string[]]
        $Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'LiteralPath')]
        [string[]]
        $LiteralPath,

        [Parameter()]
        [switch]
        $Relative,

        [Parameter()]
        [switch]
        $NoValidation,

        [Parameter(ParameterSetName = 'Path')]
        [switch]
        $ExpandEnvironmentVariables
    )

    process {
        foreach ($unresolvedPath in $MyInvocation.BoundParameters[$PSCmdlet.ParameterSetName]) {
            if ($ExpandEnvironmentVariables) {
                $unresolvedPath = [environment]::ExpandEnvironmentVariables($unresolvedPath)
            }
            $params = @{
                $($PSCmdlet.ParameterSetName) = $unresolvedPath
                ErrorAction                   = 'SilentlyContinue'
                ErrorVariable                 = 'resolvePathError'
            }
            $resolvedPath = Resolve-Path @params
            if ($null -eq $resolvedPath) {
                if ($NoValidation) {
                    $resolvedPath = $resolvePathError[0].TargetObject
                } elseif ($resolvePathError) {
                    Write-Error -ErrorRecord $resolvePathError[0]
                    Remove-Variable -Name resolvePathError
                    continue
                }
            }

            foreach ($pathInfo in $resolvedPath) {
                if ($Relative) {
                    $separator = [io.path]::DirectorySeparatorChar
                    $currentPathUri = [uri]::new($pwd.Path, [urikind]::Absolute)
                    $resolvedPathUri = [uri]::new(($pathInfo.Path -replace "([^$([regex]::Escape($separator))])`$", "`$1$([regex]::Escape($separator))"), [UriKind]::Absolute)
                    $relativePath = $currentPathUri.MakeRelativeUri($resolvedPathUri).ToString() -replace '/', [io.path]::DirectorySeparatorChar
                    if ($relativePath -notmatch "^\.+\$([io.path]::DirectorySeparatorChar)") {
                        $relativePath = '.{0}{1}' -f [io.path]::DirectorySeparatorChar, $relativePath
                    }
                    $relativePath
                } else {
                    $pathInfo
                }
            }
        }
    }
}

function Export-DeviceEventConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [MilestonePSTools.ValidateVmsItemType('Hardware', 'Camera', 'Microphone', 'Speaker', 'InputEvent')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $Device
    )

    process {
        # Using Get-ConfigurationItem just so that we have the display names since
        # they aren't available on the strongly typed HardwareDeviceEventChildItems.
        $eventDisplayNames = @{}
        (Get-ConfigurationItem -Path "HardwareDeviceEvent[$($Device.Id)]").Children | ForEach-Object {
            $id = ($_.Properties | Where-Object Key -eq 'Id').Value
            $displayName = ($_.Properties | Where-Object Key -eq 'EventIndex').DisplayName
            $eventDisplayNames[$id] = $displayName
        }
        foreach ($deviceEvent in $Device | Get-VmsDeviceEvent) {
            [pscustomobject]@{
                Event      = $deviceEvent.DisplayName
                Used       = $deviceEvent.EventUsed
                Enabled    = $deviceEvent.Enabled
                EventIndex = $deviceEvent.EventIndex
                IndexName  = $eventDisplayNames[$deviceEvent.Id]
            }
        }
    }
}

function Get-DevicePropertyList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $Device
    )

    begin {
        $excludedProperties = 'Icon', 'ItemCategory', 'Methods', 'ServerId', 'CreatedDate', 'DisplayName', 'ParentItemPath', 'StreamDefinitions', 'StreamUsages', 'Guid', 'FailoverSettingValues'
        $orderPriority = 'Name', 'ShortName', 'HostName', 'WebServerUri', 'Address', 'UserName', 'Password', 'Enabled', 'Channel', 'GisPoint', 'ActiveWebServerUri', 'PublicAccessEnabled', 'PublicWebserverHostName', 'PublicWebserverPort'
        $rearOrderPriority = 'LastModified', 'Id'

        $pathNameMap = @{}
        $childToParentMap = @{}
        $recordingStorage = @{}
        foreach ($rec in Get-VmsRecordingServer) {
            foreach ($storage in $rec | Get-VmsStorage) {
                $recordingStorage[$storage.Path] = $storage
                $pathNameMap[$storage.Path] = $storage.Name
                $pathNameMap[$rec.Path] = $rec.Name
                $childToParentMap[$storage.Path] = $rec.Path
            }
        }

        # Use translations to take an existing device property/value, and modify the column name and value in some way.
        # For example, the GisPoint property has a name unfamiliar to most users, and the "POINT(X Y)" value is even more unfamiliar.
        # Also useful for translating a config API path like "Storage[guid]" to the name of that storage.
        $translations = @{
            'GisPoint'         = {
                @{
                    Name  = 'Coordinates'
                    Value = $_.GisPoint | ConvertFrom-GisPoint
                }
            }
            'RecordingStorage' = {
                @{
                    Name  = 'Storage'
                    Value = $recordingStorage[$_.RecordingStorage].Name
                }
            }
        }

        # Properties to be added. Keys represent the name of a property after which these new properties will be added. Each scriptblock can return one or more Name/Value pairs
        $additionalProperties = @{
            'UserName'                      = {
                $hwPassword = ''
                try {
                    $hwPassword = $_ | Get-VmsHardwarePassword -ErrorAction Stop
                } catch {
                    Write-Warning "Failed to retrieve hardware password. $($_.Exception.Message)"
                }
                [pscustomobject]@{
                    Name  = 'Password'
                    Value = $hwPassword
                }
            }

            'RecordOnRelatedDevices'        = {
                $motion = $_.MotionDetectionFolder.MotionDetections[0]
                [pscustomobject]@{ Name = 'MotionEnabled'; Value = $motion.Enabled }
                [pscustomobject]@{ Name = 'MotionManualSensitivityEnabled'; Value = $motion.ManualSensitivityEnabled }
                [pscustomobject]@{ Name = 'MotionManualSensitivity'; Value = $motion.ManualSensitivity }
                [pscustomobject]@{ Name = 'MotionThreshold'; Value = $motion.Threshold }
                [pscustomobject]@{ Name = 'MotionKeyframesOnly'; Value = $motion.KeyframesOnly }
                [pscustomobject]@{ Name = 'MotionProcessTime'; Value = $motion.ProcessTime }
                [pscustomobject]@{ Name = 'MotionDetectionMethod'; Value = $motion.DetectionMethod }
                [pscustomobject]@{ Name = 'MotionGenerateMotionMetadata'; Value = $motion.GenerateMotionMetadata }
                [pscustomobject]@{ Name = 'MotionUseExcludeRegions'; Value = $motion.UseExcludeRegions }
                [pscustomobject]@{ Name = 'MotionGridSize'; Value = $motion.GridSize }
                [pscustomobject]@{ Name = 'MotionExcludeRegions'; Value = $motion.ExcludeRegions }
                [pscustomobject]@{ Name = 'MotionHardwareAccelerationMode'; Value = $motion.HardwareAccelerationMode }
            }

            'ManualRecordingTimeoutMinutes' = {
                $ptzTimeout = $_.DeviceDriverSettingsFolder.DeviceDriverSettings[0].PTZSessionTimeoutChildItem
                [pscustomobject]@{ Name = 'ManualPTZTimeout'; Value = $ptzTimeout.ManualPTZTimeout }
                [pscustomobject]@{ Name = 'PausePatrollingTimeout'; Value = $ptzTimeout.PausePatrollingTimeout }
                [pscustomobject]@{ Name = 'ReservedPTZTimeout'; Value = $ptzTimeout.ReservedPTZTimeout }
            }

            'RecordingFramerate'            = {
                $privacyMask = $_.PrivacyProtectionFolder.PrivacyProtections[0]
                [pscustomobject]@{ Name = 'PrivacyMaskEnabled'; Value = $privacyMask.Enabled }
                [pscustomobject]@{ Name = 'PrivacyMaskXml'; Value = $privacyMask.PrivacyMaskXml }
            }

            'Channel'                       = {
                $hwId = [VideoOS.Platform.Proxy.ConfigApi.ConfigurationItemPath]::new($_.ParentItemPath).Id
                $hw = [VideoOS.Platform.Configuration]::Instance.GetItem($hwId , [VideoOS.Platform.Kind]::Hardware)
                # If the hardware is disabled, the above command returns $null so we need to fallback to a reliable, but slower, method.
                if ([string]::IsNullOrEmpty($hw)) {
                    $hw = Get-VmsHardware -Id $hwId
                    $recId = [regex]::Matches($hw.ParentItemPath, '(?<=\[)[^]]+(?=\])').Value

                    [pscustomobject]@{
                        Name  = 'Address'
                        Value = $hw.Address
                    }
                    [pscustomobject]@{
                        Name  = 'Hardware'
                        Value = $hw.Name
                    }
                    [pscustomobject]@{
                        Name  = 'RecordingServer'
                        Value = $pathNameMap["RecordingServer[$($recId)]"]
                    }
                } else {
                    [pscustomobject]@{
                        Name  = 'Address'
                        Value = $hw.Properties.Address
                    }
                    [pscustomobject]@{
                        Name  = 'Hardware'
                        Value = $hw.Name
                    }
                    [pscustomobject]@{
                        Name  = 'RecordingServer'
                        Value = $pathNameMap["RecordingServer[$($hw.FQID.ServerId.Id)]"]
                    }
                }
            }

            'EdgeStoragePlaybackEnabled'    = {
                $clientSettings = $_.ClientSettingsFolder.ClientSettings[0]
                if ($clientSettings.Shortcut -eq 0 -or [string]::IsNullOrEmpty($clientSettings.Shortcut)) {
                    [pscustomobject]@{ Name = 'Shortcut'; Value = $null }
                } else {
                    [pscustomobject]@{ Name = 'Shortcut'; Value = $clientSettings.Shortcut }
                }
                [pscustomobject]@{ Name = 'MulticastEnabled'; Value = $clientSettings.MulticastEnabled }
            }

            # Add driver and recording server info after model column for hardware objects
            'Model'                         = {
                if ($hwSettings = ($_ | Get-HardwareSetting -ErrorAction SilentlyContinue)) {
                    [pscustomobject]@{
                        Name  = 'MACAddress'
                        Value = $hwSettings.MacAddress
                    }
                    [pscustomobject]@{
                        Name  = 'SerialNumber'
                        Value = $hwSettings.SerialNumber
                    }
                    [pscustomobject]@{
                        Name  = 'FirmwareVersion'
                        Value = $hwSettings.FirmwareVersion
                    }
                }
                if ($driver = ($_ | Get-VmsHardwareDriver -ErrorAction SilentlyContinue)) {
                    [pscustomobject]@{
                        Name  = 'DriverNumber'
                        Value = $driver.Number
                    }
                    [pscustomobject]@{
                        Name  = 'DriverGroup'
                        Value = $driver.GroupName
                    }
                    [pscustomobject]@{
                        Name  = 'DriverDriverType'
                        Value = $driver.DriverType
                    }
                    [pscustomobject]@{
                        Name  = 'DriverVersion'
                        Value = $driver.DriverVersion
                    }
                    [pscustomobject]@{
                        Name  = 'DriverRevision'
                        Value = $driver.DriverRevision
                    }
                }
                [pscustomobject]@{
                    Name  = 'RecordingServer'
                    Value = $pathNameMap[$_.ParentItemPath]
                }
            }
        }
    }

    process {
        $properties = ($Device | Get-Member -MemberType Property | Where-Object { $_.Name -notlike '*Folder' -and $_.Name -notlike '*Path' -and $_.Name -notin $excludedProperties }).Name

        $obj = [ordered]@{}
        foreach ($property in $orderPriority) {
            if ($null -ne $Device.$property) {
                if ($translations.ContainsKey($property)) {
                    $translations[$property].Invoke($Device) | ForEach-Object {
                        $obj.Add($_.Name, $_.Value)
                    }
                } else {
                    $obj.Add($property, $Device.$property)
                }
                if ($additionalProperties.ContainsKey($property)) {
                    $additionalProperties[$property].Invoke($Device) | ForEach-Object {
                        $obj.Add($_.Name, $_.Value)
                    }
                }
            }
        }
        foreach ($property in $properties | Where-Object { $_ -notin $orderPriority -and $_ -notin $rearOrderPriority }) {
            if ($translations.ContainsKey($property)) {
                $translations[$property].Invoke($Device) | ForEach-Object {
                    $obj.Add($_.Name, $_.Value)
                }
            } else {
                $obj.Add($property, $Device.$property)
            }
            if ($additionalProperties.ContainsKey($property)) {
                $additionalProperties[$property].Invoke($Device) | ForEach-Object {
                    $obj.Add($_.Name, $_.Value)
                }
            }
        }
        foreach ($property in $rearOrderPriority) {
            if ($null -ne $Device.$property) {
                if ($translations.ContainsKey($property)) {
                    $translations[$property].Invoke($Device) | ForEach-Object {
                        $obj.Add($_.Name, $_.Value)
                    }
                } else {
                    $obj.Add($property, $Device.$property)
                }
                if ($additionalProperties.ContainsKey($property)) {
                    $additionalProperties[$property].Invoke($Device) | ForEach-Object {
                        $obj.Add($_.Name, $_.Value)
                    }
                }
            }
        }
        [pscustomobject]$obj
    }
}

function Get-GeneralSettingList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [MilestonePSTools.ValidateVmsItemType('Hardware', 'Camera', 'Microphone', 'Speaker', 'InputEvent', 'Output', 'Metadata')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $Device
    )

    process {
        $itemType = Split-VmsConfigItemPath -Path $Device.Path -ItemType
        $parentItemId = Split-VmsConfigItemPath -Path $Device.ParentItemPath -Id
        $parentItemType = Split-VmsConfigItemPath -Path $Device.ParentItemPath -ItemType

        $commonProperties = [ordered]@{}
        switch ($parentItemType) {
            'Hardware' {
                $hwItem = [videoos.platform.configuration]::Instance.GetItem($parentItemId, [videoos.platform.kind]::Hardware)
                if ($hwItem) {
                    $recorderItem = [videoos.platform.configuration]::Instance.GetItem($hwItem.FQID.ServerId.Id, [videoos.platform.kind]::Server)
                } else {
                    # If the hardware is disabled, the $hwItem will be $null so we need to fallback to a reliable, but slower, method.
                    $hwItem = Get-VmsHardware -Id $parentItemId
                    $recId = Split-VmsConfigItemPath -Path $hwItem.ParentItemPath -Id
                    $recorderItem = [videoos.platform.configuration]::Instance.GetItem($recId, [videoos.platform.kind]::Server)
                }
                $commonProperties['RecordingServer'] = $recorderItem.Name
                $commonProperties['Hardware'] = $hwItem.Name
            }

            'RecordingServer' {
                $recorderItem = [videoos.platform.configuration]::Instance.GetItem($parentItemId, [videoos.platform.kind]::Server)
                $commonProperties['RecordingServer'] = $recorderItem.Name
            }

            Default {}
        }
        $commonProperties[$itemType] = $Device.Name
        if ($Device.Channel) {
            $commonProperties['Channel'] = $Device.Channel
        }

        $typePrefix = if ($itemType -eq 'Hardware') { 'Hardware' } else { 'Device' }
        Get-ConfigurationItem -Path "$($typePrefix)DriverSettings[$($Device.Id)]" | Select-Object -ExpandProperty Children | Where-Object ItemType -EQ "$($typePrefix)DriverSettings" | Select-Object -ExpandProperty Properties | ForEach-Object {
            $property = $_
            $displayValue = ($property.ValueTypeInfos | Where-Object Value -EQ $property.Value).Name
            $key = $property.Key
            if ($key -match '^([^/]+/)(?<key>[^/]+)(/[^/]+)?$') {
                $key = $Matches.key
            }
            $row = [ordered]@{}
            $commonProperties.Keys | ForEach-Object { $row[$_] = $commonProperties[$_] }
            $row.Setting = $key
            $row.Value = $property.Value
            $row.DisplayValue = if ($property.ValueType -eq 'Enum' -and $displayValue -ne $property.Value) { $displayValue } else { $null }
            $row.ReadOnly = !$property.IsSettable
            [pscustomobject]$row
        }
    }
}

function Import-DeviceEventConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [MilestonePSTools.ValidateVmsItemType('Hardware', 'Camera', 'Microphone', 'Speaker', 'InputEvent')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $Device,

        [Parameter(Mandatory)]
        [pscustomobject[]]
        $Settings
    )

    process {
        foreach ($eventRow in $Settings) {
            if ($deviceEvent = $Device | Get-VmsDeviceEvent -Name $eventRow.EventName) {
                $setEventArgs = @{
                    Used    = $script:Truthy.IsMatch($eventRow.Used)
                    Enabled = $script:Truthy.IsMatch($eventRow.Enabled)
                    Index   = $eventRow.EventIndex
                    Verbose = $VerbosePreference
                }
                if ($deviceEvent.EventUsed -ne $setEventArgs.Used) {
                    $deviceEvent | Set-VmsDeviceEvent @setEventArgs
                }
            } else {
                Write-Warning "Device '$($Device.Name)' does not have a device event setting with the key '$($eventRow.EventName)'."
            }
        }
    }
}

function Import-DevicePropertyList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $Device,

        [Parameter(Mandatory)]
        [pscustomobject]
        $Settings
    )

    begin {
        $ignoredColumns = 'RecordingServer', 'Hardware', 'Address', 'LastModified', 'Id', 'MotionDetectionMethod', 'MotionGenerateMotionMetadata', 'MotionGridSize', 'MotionExcludeRegions', 'MotionHardwareAccelerationMode', 'MotionKeyframesOnly', 'MotionManualSensitivity', 'MotionManualSensitivityEnabled', 'MotionProcessTime', 'MotionThreshold', 'MotionUseExcludeRegions', 'PrivacyMaskXml', 'PausePatrollingTimeout', 'ReservedPTZTimeout', 'MulticastEnabled', 'Guid', 'FailoverSettingValues'
        $recordingStorage = @{}
        Get-VmsRecordingServer -Name $Settings.RecordingServer | Get-VmsStorage | ForEach-Object {
            $recordingStorage[$_.Name] = $_
        }

        $translations = @{
            'Coordinates' = {
                param($item, $settings)
                try {
                    @{
                        Name  = 'GisPoint'
                        Value = if ($settings.Coordinates -eq 'Unknown' -or [string]::IsNullOrWhiteSpace($settings.Coordinates)) { 'POINT EMPTY' } else { ConvertTo-GisPoint -Coordinates $settings.Coordinates -ErrorAction Stop }
                    }
                } catch {
                    Write-Warning "Failed to convert value '$($settings.Coordinates)' to a GisPoint value compatible with Milestone."
                }
            }
            'Storage'     = {
                param($item, $settings)
                if ($recordingStorage.ContainsKey($settings.Storage)) {
                    @{
                        Name  = 'RecordingStorage'
                        Value = $recordingStorage[$settings.Storage].Path
                    }
                } else {
                    Write-Warning "Storage configuration '$($settings.Storage)' not found on recording server $($settings.RecordingServer)"
                }
            }
        }

        $customHandlers = @{
            'Enabled'            = {
                param($item, $settings)
                $enabled = $false
                if (-not [string]::IsNullOrWhiteSpace($settings.Enabled) -and [bool]::TryParse($settings.Enabled, [ref]$enabled) -and $item.EnableProperty.Enabled -ne $enabled) {
                    Write-Verbose "Changing 'Enabled' to $enabled on $($item.DisplayName)"
                    $item.EnableProperty.Enabled = $enabled
                    return $true
                }
                return $false
            }

            'RecordingStorage'   = {
                param($item, $settings)
                try {
                    $storagePath = $recordingStorage[$settings.Storage].Path
                    if ($null -eq $storagePath) {
                        throw "Storage configuration named '$($settings.Storage)' not found."
                    }
                    if ($storagePath -eq ($item.Properties | Where-Object Key -EQ 'RecordingStorage').Value) {
                        return $true
                    }
                    $invokeInfo = $item | Invoke-Method -MethodId 'ChangeDeviceRecordingStorage'
                    foreach ($p in $invokeInfo.Properties) {
                        switch ($p.Key) {
                            'ItemSelection' { $p.Value = $storagePath }
                            'moveData' { $p.Value = $false }
                        }
                    }
                    $invokeResult = $invokeInfo | Invoke-Method -MethodId 'ChangeDeviceRecordingStorage'
                    $taskPath = ($invokeResult.Properties | Where-Object Key -EQ 'Path').Value
                    if ($taskPath) {
                        $null = Wait-VmsTask -Path $taskPath -Cleanup
                    }
                    return $true
                } catch {
                    Write-Warning $_.Exception.Message
                }
                return $false
            }

            'MotionEnabled'      = {
                param($item, $settings)
                $motion = Get-ConfigurationItem -Path "MotionDetection[$(($item.Properties | Where-Object Key -EQ Id).Value)]"
                $dirty = $false
                foreach ($column in $settings | Get-Member -MemberType NoteProperty -Name Motion* | Select-Object -ExpandProperty Name) {
                    if ([string]::IsNullOrWhiteSpace($settings.$column)) {
                        continue
                    }
                    $key = $column -replace '^Motion', ''
                    if ($key -eq 'Enabled') {
                        $newValue = $script:Truthy.IsMatch($settings.$column)
                        if ($motion.EnableProperty.Enabled -ne $newValue) {
                            $motion.EnableProperty.Enabled = $newValue
                            $dirty = $true
                        }
                    } else {
                        $property = $motion.Properties | Where-Object Key -EQ $key
                        if ($property.Value -ne $settings.$column) {
                            $property.Value = $settings.$column
                            $dirty = $true
                        }
                    }
                }
                if ($dirty) {
                    $result = $motion | Set-ConfigurationItem
                    if (-not $result.ValidatedOk) {
                        foreach ($errorResult in $result.ErrorResults) {
                            Write-Warning "Failed to update motion detection settings for $($item.DisplayName). $($errorResult.ErrorText)."
                        }
                    }
                }
            }

            'ManualPTZTimeout'   = {
                param($item, $settings)
                $deviceDriverSettings = Get-ConfigurationItem -Path "DeviceDriverSettings[$(($item.Properties | Where-Object Key -EQ Id).Value)]"
                $dirty = $false
                foreach ($column in $settings | Get-Member -MemberType NoteProperty -Name ManualPTZTimeout, PausePatrollingTimeout, ReservedPTZTimeout | Select-Object -ExpandProperty Name) {
                    if ([string]::IsNullOrWhiteSpace($settings.$column)) {
                        continue
                    }
                    $key = $column
                    $property = ($deviceDriverSettings.Children | Where-Object { $_.ItemType -eq 'PTZSessionTimeout' }).Properties | Where-Object Key -EQ $key
                    if ($property) {
                        if ($property.Value -ne $settings.$column) {
                            $property.Value = $settings.$column
                            $dirty = $true
                        }
                    } else {
                        Write-Warning "No PTZSessionTimeout property found in $($item.DisplayName) DeviceDriverSettings named $key"
                    }
                }
                if ($dirty) {
                    $result = $deviceDriverSettings | Set-ConfigurationItem
                    if (-not $result.ValidatedOk) {
                        foreach ($errorResult in $result.ErrorResults) {
                            Write-Warning "Failed to update PTZ session timeout settings for $($item.DisplayName). $($errorResult.ErrorText)."
                        }
                    }
                }
            }

            'PrivacyMaskEnabled' = {
                param($item, $settings)
                $privacyMask = Get-ConfigurationItem -Path "PrivacyProtection[$(($item.Properties | Where-Object Key -EQ Id).Value)]"
                $dirty = $false
                foreach ($column in $settings | Get-Member -MemberType NoteProperty -Name PrivacyMask* | Select-Object -ExpandProperty Name) {
                    if ([string]::IsNullOrWhiteSpace($settings.$column)) {
                        continue
                    }

                    $key = $column
                    if ($key -eq 'PrivacyMaskEnabled') {
                        $newValue = 'True' -eq $settings.$column
                        if ($privacyMask.EnableProperty.Enabled -ne $newValue) {
                            $privacyMask.EnableProperty.Enabled = $newValue
                            $dirty = $true
                        }
                    } elseif ($key -eq 'PrivacyMaskXml') {
                        $property = $privacyMask.Properties | Where-Object Key -EQ $key
                        if ($property.Value -ne $settings.$column) {
                            $property.Value = $settings.$column
                            $dirty = $true
                        }
                    }
                }
                if ($dirty) {
                    $result = $privacyMask | Set-ConfigurationItem
                    if (-not $result.ValidatedOk) {
                        foreach ($errorResult in $result.ErrorResults) {
                            Write-Warning "Failed to update privacy mask settings for $($item.DisplayName). $($errorResult.ErrorText)."
                        }
                    }
                }
            }

            'Shortcut'           = {
                param($item, $settings)
                $clientSettings = Get-ConfigurationItem -Path "ClientSettings[$(($item.Properties | Where-Object Key -EQ Id).Value)]"
                $dirty = $false
                foreach ($column in $settings | Get-Member -MemberType NoteProperty -Name Shortcut, MulticastEnabled | Select-Object -ExpandProperty Name) {
                    if ([string]::IsNullOrWhiteSpace($settings.$column)) {
                        continue
                    }

                    $key = $column
                    if ($key -eq 'MulticastEnabled') {
                        $newValue = 'True' -eq $settings.$column
                        $property = $clientSettings.Properties | Where-Object Key -EQ $key
                        if ($null -eq $property) {
                            Write-Verbose "Property '$column' not found in ClientSettings for $($item.DisplayName). It may not be available on this VMS version."
                            continue
                        }
                        if ($property.Value -ne $newValue) {
                            $property.Value = $newValue
                            $dirty = $true
                        }
                    } elseif ($key -eq 'Shortcut') {
                        $property = $clientSettings.Properties | Where-Object Key -EQ $key
                        if ($null -eq $property) {
                            Write-Verbose "Property '$column' not found in ClientSettings for $($item.DisplayName). It may not be available on this VMS version."
                            continue
                        }
                        if ($property.Value -ne $settings.$column -and $settings.$column -ge 1) {
                            $property.Value = $settings.$column
                            $dirty = $true
                        }
                    }
                }
                if ($dirty) {
                    $result = $clientSettings | Set-ConfigurationItem
                    if (-not $result.ValidatedOk) {
                        foreach ($errorResult in $result.ErrorResults) {
                            Write-Warning "Failed to update privacy mask settings for $($item.DisplayName). $($errorResult.ErrorText)."
                        }
                    }
                }
            }
        }
    }

    process {
        $dirty = $false
        $properties = @{}
        $item = $Device | Get-ConfigurationItem
        $item.Properties | ForEach-Object { $properties[$_.Key] = $_ }

        foreach ($columnName in $Settings | Get-Member -MemberType NoteProperty | Where-Object Name -NotIn $ignoredColumns | Select-Object -ExpandProperty Name) {
            $newValue = $Settings.$columnName
            if ($translations.ContainsKey($columnName)) {
                $columnName, $newValue = $translations[$columnName].Invoke($item, $Settings) | ForEach-Object {
                    Write-Verbose "Translating column name '$($columnName)' to '$($_.Name)', and value '$($newValue)' to '$($_.Value)'"
                    @($_.Name, $_.Value)
                }
                if ($null -eq $columnName -or $null -eq $newValue) {
                    Write-Verbose 'Failed to translate column/value. No change will be made for this property.'
                    continue
                }
            }

            if ($customHandlers.ContainsKey($columnName)) {
                Write-Verbose "Invoking custom handler for column $columnName on device $($Device.Name)"
                if ($customHandlers[$columnName].Invoke($item, $Settings)) {
                    $dirty = $true
                }
            } else {
                $property = $properties[$columnName]
                if ($property) {
                    if ($property.Value -ne $newValue) {
                        Write-Verbose "Setting $columnName to $newValue on $($Device.Name)"
                        $property.Value = $newValue
                        $dirty = $true
                    } else {
                        Write-Verbose "Setting $columnName already has value $newValue on $($Device.Name)"
                    }
                } else {
                    Write-Warning "Property '$($columnName)' not found on $($Device.Name)"
                }
            }
        }

        # Update the name for the in-memory copy of $Device so that the verbose logging doesn't mention the old name anymore.
        $Device.Name = ($item.Properties | Where-Object Key -EQ 'Name').Value

        if ($dirty) {
            Write-Verbose "Saving changes to $($Device.Name)"
            $result = $item | Set-ConfigurationItem
            foreach ($entry in $result.ErrorResults) {
                Write-Error -Message "Validation error: $($entry.ErrorText) on '$($Device.Name)'."
            }
        } else {
            Write-Verbose "No changes made to $($Device.Name)"
        }
    }
}

function Import-GeneralSettingList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $Device,

        [Parameter(Mandatory)]
        [pscustomobject[]]
        $Settings
    )

    begin {
        $validDeviceTypes = @('Hardware', 'Camera', 'Microphone', 'Speaker', 'InputEvent', 'Output', 'Metadata')
    }

    process {
        $devicePath = [VideoOS.Platform.Proxy.ConfigApi.ConfigurationItemPath]::new($Device.Path)
        if ($devicePath.ItemType -notin $validDeviceTypes) {
            Write-Error 'Invalid device type for this cmdlet.'
            return
        }

        $itemType = if ($devicePath.ItemType -eq 'Hardware') { 'Hardware' } else { 'Device' }
        Write-Verbose "$($devicePath.ItemType)GeneralSettings: Checking general settings for '$($Device.Name)'"
        $item = Get-ConfigurationItem -Path "$($itemType)DriverSettings[$($Device.Id)]"
        $general = $item.Children | Where-Object ItemType -EQ "$($itemType)DriverSettings"
        $dirty = $false
        foreach ($setting in $Settings) {
            $property = $general.Properties | Where-Object Key -Match "^([^/]+/)?(?<key>$([regex]::Escape($setting.Setting)))(/[^/]+)?$" | Select-Object -First 1
            $key = $setting.Setting
            
            if ($null -eq $property) {
                Write-Warning "$($devicePath.ItemType)GeneralSettings: Device '$($Device.Name)' does not have a general setting with the key '$($setting.Setting)'."
                continue
            } elseif (!$property.IsSettable) {
                continue
            }
            $incomingValue = $setting.Value
            if ($property.ValueType -eq 'Enum' -and $incomingValue -in $property.ValueTypeInfos.Value) {
                # Handle incorrect case for incoming settings by doing case-insensitive check against
                # available enum values.
                $incomingValue = $property.ValueTypeInfos.Value | Where-Object { $_ -eq $incomingValue }
            }
            if ($property.Value -cne $incomingValue) {
                Write-Verbose "$($devicePath.ItemType)GeneralSettings: Changing $($property.DisplayName) ($key) to '$($incomingValue)'"
                $property.Value = $incomingValue
                $dirty = $true
            } else {
                Write-Verbose "$($devicePath.ItemType)GeneralSettings: Keeping $($property.DisplayName) ($key) value '$($property.Value)'"
            }
        }

        if (-not $dirty) {
            Write-Verbose "$($devicePath.ItemType)GeneralSettings: No changes to general settings were required for '$($Device.Name)'"
            return
        }

        Write-Verbose "$($devicePath.ItemType)GeneralSettings: Saving changes to general settings for '$($Device.Name)'"
        $result = $item | Set-ConfigurationItem
        foreach ($entry in $result.ErrorResults) {
            Write-Error -Message "$($devicePath.ItemType)GeneralSettings: Validation error: $($entry.ErrorText) on '$($Device.Name)'."
        }
    }
}


function Export-VmsHardwareExcel {
    <#
    .SYNOPSIS
    Exports hardware configuration in Microsoft Excel XLSX format.

    .DESCRIPTION
    The `Export-VmsHardwareExcel` cmdlet accepts one or more Hardware objects
    from `Get-VmsHardware` and exports detailed configuration to an Excel XLSX
    document.

    The document will contain multiple worksheets, depending on which device
    types are specified in the `IncludedDevices` parameter. Each area of the
    hardware configuration is represented in it's own worksheet which makes it
    possible to represent many different types of objects and settings in the
    same document while keeping it human-readable and easy to modify.

    .PARAMETER Hardware
    Specifies one or more Hardware objects returned by `Get-VmsHardware`. If no
    hardware is provided, then all hardware found in the VMS matching the
    desired `EnableState` will be exported.

    .PARAMETER Path
    The absolute, or relative path, including filename, where the .XLSX file
    should be saved. If no path is provided, a save-file dialog will be shown.

    .PARAMETER IncludedDevices
    Defaults to "Cameras". Specifies the types of child devices to include in the export. It can be
    very time consuming to export configuration for thousands of devices, and
    if you only need camera and metadata settings, you can specify this and
    avoid retrieving detailed configuration on microphones, speakers, inputs,
    and outputs.

    .PARAMETER EnableFilter
    Defaults to "Enabled". Filters the exported hardware and devices to only
    those matching the specified EnableFilter.

    .PARAMETER Force
    Overwrite an existing file if the file specified in `Path` already exists.

    .EXAMPLE
    Export-VmsHardwareExcel -Path ~\Documents\hardware.xlsx -Verbose

    Exports configuration for all enabled hardware, and cameras to the current
    user's Documents directory.

    .EXAMPLE
    Export-VmsHardwareExcel -Path ~\Documents\hardware.xlsx -IncludedDevices Cameras, Microphones -Verbose

    Exports configuration for all enabled hardware, cameras, and microphones to
    the current user's Documents directory.

    .EXAMPLE
    $hardware = Get-VmsRecordingServer -Name Recorder1 | Get-VmsHardware
    Export-VmsHardwareExcel -Hardware $hardware -Path ~\Desktop\hardware.xlsx -Verbose

    Exports configuration for all enabled hardware, and cameras on the
    recording server named "Recorder1" tp the current user's Desktop.

    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.Hardware[]]
        $Hardware,

        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [ValidateSet('Camera', 'Microphone', 'Speaker', 'Metadata', 'Input', 'Output')]
        [string[]]
        $IncludedDevices = @('Camera'),

        [Parameter()]
        [ValidateSet('All', 'Disabled', 'Enabled')]
        [string]
        $EnableFilter = 'Enabled',

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        if ([string]::IsNullOrWhiteSpace($Path)) {
            $Path = Show-FileDialog -SaveFile
        }
        if (Test-Path $Path) {
            throw ([io.ioexception]::new("File $Path already exists."))
        } else {
            $directoryPath = Split-Path -Path $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path) -Parent
            $null = New-Item -Path $directoryPath -ItemType Directory -Force
        }
        $excelPackage = Open-ExcelPackage -Path $Path -Create
        $worksheets = @(
            'Hardware',
            'HardwareGeneralSettings',
            'HardwarePtzSettings',
            'HardwareEvents',
            'Cameras',
            'CameraGeneralSettings',
            'CameraStreams',
            'CameraStreamSettings',
            'CameraPtzPresets',
            'CameraPtzPatrols',
            'CameraPtzPatrolPresets',
            'CameraRelatedDevices',
            'CameraEvents',
            'CameraGroups',
            'Microphones',
            'MicrophoneGeneralSettings',
            'MicrophoneStreamSettings',
            'MicrophoneEvents',
            'MicrophoneGroups',
            'Speakers',
            'SpeakerGeneralSettings',
            'SpeakerEvents',
            'SpeakerGroups',
            'Metadata',
            'MetadataGeneralSettings',
            'MetadataGroups',
            'Inputs',
            'InputGeneralSettings',
            'InputEvents',
            'InputGroups'
            'Outputs',
            'OutputGeneralSettings',
            'OutputGroups'
        )
        $null = $worksheets | ForEach-Object { $excelPackage.Workbook.Worksheets.Add($_) }
        Clear-VmsCache
    }

    process {
        $progress = @{
            Activity         = 'Exporting hardware configuration to {0}' -f $Path
            Id               = 11
            PercentComplete  = 0
            CurrentOperation = 'Preparing'
        }
        Write-Progress @progress

        if ($IncludedDevices) {
            $IncludedDevices = $IncludedDevices | Group-Object | Select-Object -ExpandProperty Name
        }


        $progress.CurrentOperation = 'Retrieving list of recording servers'
        Write-Progress @progress
        Write-Verbose 'Retrieving recording server list'
        $recorderMap = @{}
        Get-VmsRecordingServer | ForEach-Object {
            $recorderMap[$_.Path] = $_
        }

        if ($null -eq $Hardware) {
            $progress.CurrentOperation = 'Retrieving list of hardware to be exported'
            Write-Progress @progress
            $Hardware = Get-VmsHardware
        }

        Write-Verbose 'Loading device groups'
        $deviceGroups = @{}
        $IncludedDevices | ForEach-Object {
            $type = $_ -replace 's$', ''
            foreach ($group in Get-VmsDeviceGroup -Type $type -Recurse) {
                $members = $group | Get-VmsDeviceGroupMember -EnableFilter $EnableFilter
                if ($members.Count -eq 0) { continue }
                
                $groupPath = $group | Resolve-VmsDeviceGroupPath -NoTypePrefix
                foreach ($member in $members) {
                    if (-not $deviceGroups.ContainsKey($member.Id)) {
                        $deviceGroups[$member.Id] = [list[string]]::new()
                    }
                    $deviceGroups[$member.Id].Add($groupPath)
                }
            }
        }

        $excelParams = @{
            ExcelPackage       = $excelPackage
            TableStyle         = 'Medium9'
            AutoSize           = $true
            Append             = $true
            NoNumberConversion = 'Value', 'DisplayValue', 'MotionExcludeRegions', 'MACAddress', 'SerialNumber', 'FirmwareVersion', 'Password'
            PassThru           = $true
        }

        $totalHardwareCount = $Hardware.Count
        $processedHardwareCount = 0
        $Hardware | ForEach-Object {
            $hw = $_
            $progress.PercentComplete = [math]::Round(($processedHardwareCount++) / $totalHardwareCount * 100)
            $progress.CurrentOperation = '{0} "{1}"' -f [VideoOS.Platform.Proxy.ConfigApi.ConfigurationItemPath]::new($_.Path).ItemType, $_.Name
            Write-Progress @progress
            if (($EnableFilter -eq 'Enabled' -and -not $hw.Enabled) -or ($EnableFilter -eq 'Disabled' -and $hw.Enabled)) {
                Write-Verbose "Skipping hardware $($hw.Name) due to the EnableFilter value of $EnableFilter"
                return
            }
            Write-Verbose "Retrieving hardware properties for $($hw.Name)"
            $null = $hw | Get-DevicePropertyList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName Hardware -TableName HardwareList }

            Write-Verbose "Retrieving general setting properties for $($hw.Name)"
            $null = $hw | Get-GeneralSettingList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName HardwareGeneralSettings -TableName HardwareGeneralSettingsList }

            $channel = 0
            $hw.HardwarePtzSettingsFolder.HardwarePtzSettings.HardwarePtzDeviceSettingChildItems | Where-Object { $null -ne $_ } | ForEach-Object {
                $hwPtzSettings = @(

                    @{
                        Name       = 'RecordingServer'
                        Expression = { $recorderMap[$hw.ParentItemPath].Name }
                    },
                    @{
                        Name       = 'Hardware'
                        Expression = { $hw.Name }
                    },
                    @{
                        Name       = 'Camera'
                        Expression = { $_.DisplayName }
                    },
                    @{
                        Name       = 'Channel'
                        Expression = { $channel }
                    },
                    @{
                        Name       = 'PTZEnabled'
                        Expression = { $_.Properties.GetValue('PTZEnabled') }
                    },
                    @{
                        Name       = 'PTZDeviceID'
                        Expression = { $_.Properties.GetValue('PTZDeviceID') }
                    },
                    @{
                        Name       = 'PTZCOMPort'
                        Expression = { $_.Properties.GetValue('PTZCOMPort') }
                    },
                    @{
                        Name       = 'PTZProtocol'
                        Expression = { $_.Properties.GetValue('PTZProtocol') }
                    }
                )
                $null = $_ | Select-Object $hwPtzSettings | Export-Excel @excelParams -WorksheetName HardwarePtzSettings -TableName HardwarePtzSettingsList
                $channel += 1
            }

            Write-Verbose "Retrieving event properties for $($hw.Name)"
            $obj = [ordered]@{
                RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                Hardware        = $hw.Name
            }
            $null = $hw | Export-DeviceEventConfig | ForEach-Object {
                $eventInfo = $_
                $obj.EventName = $eventInfo.Event
                $obj.Used = $eventInfo.Used
                $obj.Enabled = $eventInfo.Enabled
                $obj.EventIndex = $eventInfo.EventIndex
                $obj.IndexName = $eventInfo.IndexName
                [pscustomobject]$obj | Export-Excel @excelParams -WorksheetName HardwareEvents -TableName HardwareEventsList
            }

            if ('Camera' -in $IncludedDevices) {
                $hw | Get-VmsCamera -EnableFilter $EnableFilter | ForEach-Object {
                    Write-Verbose "Retrieving camera properties for $($_.Name)"
                    $cam = $_
                    $progress.CurrentOperation = '{0} "{1}"' -f [VideoOS.Platform.Proxy.ConfigApi.ConfigurationItemPath]::new($_.Path).ItemType, $_.Name
                    Write-Progress @progress
                    $null = $cam | Get-DevicePropertyList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName Cameras -TableName CamerasList }

                    Write-Verbose "Retrieving general setting properties for $($cam.Name)"
                    $null = $cam | Get-GeneralSettingList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName CameraGeneralSettings -TableName CameraGeneralSettingsList }

                    Write-Verbose "Retrieving stream properties for $($cam.Name)"
                    $recordingTrack = @{
                        '16ce3aa1-5f93-458a-abe5-5c95d9ed1372' = 'Primary'
                        '84fff8b9-8cd1-46b2-a451-c4a87d4cbbb0' = 'Secondary'
                        ''                                     = 'None'
                    }
                    $supportsAdaptivePlayback = [version](Get-VmsManagementServer).Version -ge '23.2'
                    $cam | Get-VmsCameraStream -Enabled -RawValues | ForEach-Object {
                        $stream = $_
                        $obj = [pscustomobject]@{
                            RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                            Hardware        = $hw.Name
                            Camera          = $cam.Name
                            Channel         = $cam.Channel

                            Name            = $stream.Name
                            DisplayName     = $stream.DisplayName
                            LiveMode        = $stream.LiveMode
                            LiveDefault     = $stream.LiveDefault
                            PlaybackDefault = $stream.PlaybackDefault
                            RecordingTrack  = if ($supportsAdaptivePlayback) { $recordingTrack["$($stream.RecordingTrack)"] } elseif ($stream.Recorded) { 'Primary' } else { 'None' }
                            UseEdge         = $stream.UseEdge
                        }
                        $null = $obj | Export-Excel @excelParams -WorksheetName CameraStreams -TableName CameraStreamsList

                        $null = $stream.Settings.Keys | ForEach-Object {
                            $key = $_
                            $displayValue = ($stream.ValueTypeInfo[$key] | Where-Object { $_.Value -eq $property.Value -and $_.Name -notlike '*Value' }).Name
                            [pscustomobject]@{
                                RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                                Hardware        = $hw.Name
                                Camera          = $cam.Name
                                Channel         = $cam.Channel
                                Stream          = $stream.Name

                                Setting         = $key
                                Value           = $stream.Settings[$key]
                                DisplayValue    = if ($stream.Settings[$key] -ne $displayValue) { $displayValue } else { $null }
                            } | Export-Excel @excelParams -WorksheetName CameraStreamSettings -TableName CameraStreamSettingsList
                        }
                    }

                    Write-Verbose "Retrieving system PTZ presets for $($cam.Name)"
                    $cam.PtzPresetFolder.PtzPresets | Where-Object { $null -ne $_ } | ForEach-Object {
                        $ptzPreset = $_
                        if ($ptzPreset.DevicePreset) {
                            Write-Verbose "Camera $($cam.Name) has preset positions defined on camera and not in the VMS."
                            return
                        }
                        $obj = [pscustomobject]@{
                            RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                            Hardware        = $hw.Name
                            Camera          = $cam.Name
                            Channel         = $cam.Channel

                            DefaultPreset   = $ptzPreset.DefaultPreset
                            Pan             = $ptzPreset.Pan 
                            Tilt            = $ptzPreset.Tilt
                            Zoom            = $ptzPreset.Zoom
                            Name            = $ptzPreset.Name
                            Description     = $ptzPreset.Description
                        }
                        $null = $obj | Export-Excel @excelParams -WorksheetName CameraPtzPresets -TableName CameraPtzPresetsList
                    }

                    Write-Verbose "Retrieving system PTZ patrols for $($cam.Name)"
                    $ptzPresets = $cam.PtzPresetFolder.PtzPresets
                    $cam.PatrollingProfileFolder.PatrollingProfiles | Where-Object { $null -ne $_ } | ForEach-Object {
                        $ptzPatrol = $_
                        if ($cam.PtzPresetFolder.PtzPresets[0].DevicePreset) {
                            Write-Verbose "Camera $($cam.Name) has preset positions defined on camera so skipping PTZ patrolling profiles."
                            return
                        }
                        $obj = [pscustomobject]@{
                            RecordingServer      = $recorderMap[$hw.ParentItemPath].Name
                            Hardware             = $hw.Name
                            Camera               = $cam.Name
                            Channel              = $cam.Channel

                            Name                 = $ptzPatrol.Name
                            Description          = $ptzPatrol.Description
                            CustomizeTransitions = $ptzPatrol.CustomizeTransitions
                            InitSpeed            = $ptzPatrol.InitSpeed
                            InitTransitionTime   = $ptzPatrol.InitTransitionTime
                            EndPresetId          = $ptzPatrol.EndPresetId
                            EndPresetName        = ($ptzPresets | Where-Object Id -EQ $ptzPatrol.EndPresetId).Name
                            EndSpeed             = $ptzPatrol.EndSpeed
                            EndTransitionTime    = $ptzPatrol.EndTransitionTime

                        }
                        $null = $obj | Export-Excel @excelParams -WorksheetName CameraPtzPatrols -TableName CameraPtzPatrolsList

                        Write-Verbose "Retrieving PTZ patrols presets for $($ptzPatrol.Name) on $($cam.Name)"
                        $patrolChildren = (Get-ConfigurationItem -Path "PatrollingProfile[$($ptzPatrol.Id)]").Children

                        for ($i = 0; $i -lt $patrolChildren.Count; $i++) {
                            $patrolChild = $patrolChildren | Where-Object { $_.Path -eq "PatrollingEntry[$($i)]" }
                            $presetId = ($patrolChild.Properties | Where-Object Key -EQ PresetId).Value

                            $obj = [pscustomobject]@{
                                RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                                Hardware        = $hw.Name
                                Camera          = $cam.Name
                                Channel         = $cam.Channel
                                Patrol          = $ptzPatrol.Name

                                Order           = ($patrolChild.Properties | Where-Object Key -EQ Order).Value
                                WaitTime        = ($patrolChild.Properties | Where-Object Key -EQ WaitTime).Value
                                Speed           = ($patrolChild.Properties | Where-Object Key -EQ Speed).Value
                                TransitionTime  = ($patrolChild.Properties | Where-Object Key -EQ TransitionTime).Value
                                PresetName      = ($ptzPresets | Where-Object { $_.Id -eq $presetId }).Name
                            }
                            $null = $obj | Export-Excel @excelParams -WorksheetName CameraPtzPatrolPresets -TableName CameraPtzPatrolPresetsList
                        }
                    }

                    Write-Verbose "Retrieving related devices, shortcut number, and multicast setting for $($cam.Name)"
                    $clientSettings = $cam.ClientSettingsFolder.ClientSettings[0]
                    if (-not [string]::IsNullOrEmpty($clientSettings.Related)) {
                        $relatedDevices = [list[pscustomobject]]::new()
                        $clientSettings.Related.Split(',') | ForEach-Object {
                            $deviceType = $_.Split('[') | Select-Object -First 1
                            $deviceCI = Get-ConfigurationItem -Path $_
                            $deviceProperties = $deviceCI.Properties
                            $hardwarePath = $deviceCI.ParentPath.Split('/') | Select-Object -First 1
                            $hardwareCI = Get-ConfigurationItem -Path $hardwarePath
                            $hardwareProperties = $hardwareCI.Properties
                            $recordingServerPath = $hardwareCI.ParentPath.Split('/') | Select-Object -First 1
                            $recordingServerCI = Get-ConfigurationItem -Path $recordingServerPath
                            $recordingServerProperties = $recordingServerCI.Properties

                            $row = [PSCustomObject]@{
                                RelatedDeviceType              = $deviceType
                                RelatedRecordingServerName     = ($recordingServerProperties | Where-Object Key -EQ Name).Value
                                RelatedRecordingServerHostName = ($recordingServerProperties | Where-Object Key -EQ HostName).Value
                                RelatedHardwareName            = ($hardwareProperties | Where-Object Key -EQ Name).Value
                                RelatedHardwareAddress         = ($hardwareProperties | Where-Object Key -EQ Address).Value
                                RelatedDeviceName              = ($deviceProperties | Where-Object Key -EQ Name).Value
                                RelatedDeviceChannel           = ($deviceProperties | Where-Object Key -EQ Channel).Value
                            }
                            $relatedDevices.Add($row)
                        }
                    } else {
                        $relatedDevices = $null
                    }

                    foreach ($relatedDevice in $relatedDevices) {
                        $obj = [pscustomobject]@{
                            RecordingServer                = $recorderMap[$hw.ParentItemPath].Name
                            Hardware                       = $hw.Name
                            Camera                         = $cam.Name
                            Channel                        = $cam.Channel

                            RelatedDeviceType              = $relatedDevice.RelatedDeviceType
                            RelatedRecordingServerName     = $relatedDevice.RelatedRecordingServerName
                            RelatedRecordingServerHostName = $relatedDevice.RelatedRecordingServerHostName
                            RelatedHardwareName            = $relatedDevice.RelatedHardwareName
                            RelatedHardwareAddress         = $relatedDevice.RelatedHardwareAddress
                            RelatedDeviceName              = $relatedDevice.RelatedDeviceName
                            RelatedDeviceChannel           = $relatedDevice.RelatedDeviceChannel
                            Shortcut                       = $clientSettings.Shortcut
                            MulticastEnabled               = $clientSettings.MulticastEnabled
                        }
                        $null = $obj | Export-Excel @excelParams -WorksheetName CameraRelatedDevices -TableName CameraRelatedDevicesList
                    }

                    Write-Verbose "Retrieving event properties for $($cam.Name)"
                    $obj = [ordered]@{
                        RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                        Hardware        = $hw.Name
                        Camera          = $cam.Name
                    }
                    $null = $cam | Export-DeviceEventConfig | ForEach-Object {
                        $eventInfo = $_
                        $obj.EventName = $eventInfo.Event
                        $obj.Used = $eventInfo.Used
                        $obj.Enabled = $eventInfo.Enabled
                        $obj.EventIndex = $eventInfo.EventIndex
                        $obj.IndexName = $eventInfo.IndexName
                        [pscustomobject]$obj | Export-Excel @excelParams -WorksheetName CameraEvents -TableName CameraEventsList
                    }

                    Write-Verbose "Retrieving device groups for $($cam.Name)"
                    if ($deviceGroups.ContainsKey($cam.Id)) {
                        $null = $deviceGroups[$cam.Id] | ForEach-Object {
                            [pscustomobject]@{
                                RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                                Hardware        = $hw.Name
                                Camera          = $cam.Name
                                Group           = $_
                            }
                        } | Export-Excel @excelParams -WorksheetName CameraGroups -TableName CameraGroupsList
                    }
                }
            }

            if ('Microphone' -in $IncludedDevices) {
                $deviceType = 'Microphone'
                $deviceTypePlural = "Microphones"

                $hw | Get-VmsMicrophone -EnableFilter $EnableFilter | ForEach-Object {
                    $progress.CurrentOperation = '{0} "{1}"' -f [VideoOS.Platform.Proxy.ConfigApi.ConfigurationItemPath]::new($_.Path).ItemType, $_.Name
                    Write-Progress @progress
                    $device = $_
                    if (($EnableFilter -eq 'Enabled' -and -not $device.Enabled) -or ($EnableFilter -eq 'Disabled' -and $device.Enabled)) {
                        Write-Verbose "Skipping $deviceType $($device.Name) due to the EnableFilter value of $EnableFilter"
                        return
                    }

                    Write-Verbose "Retrieving $deviceType properties for $($device.Name)"
                    $null = $device | Get-DevicePropertyList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName $deviceTypePlural -TableName "$($deviceTypePlural)List" }

                    Write-Verbose "Retrieving general setting properties for $($device.Name)"
                    $null = $device | Get-GeneralSettingList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName "$($deviceType)GeneralSettings" -TableName "$($deviceType)GeneralSettingsList" }

                    Write-Verbose "Retrieving stream properties for $($device.Name)"
                    $deviceDriverSettings | Select-Object -ExpandProperty Children | Where-Object ItemType -EQ Stream | Select-Object -ExpandProperty Properties | Where-Object IsSettable | ForEach-Object {
                        if ($null -eq $_) {
                            return
                        }
                        $property = $_
                        $key = $property.Key
                        $displayValue = ($property.ValueTypeInfos | Where-Object Value -EQ $property.Value).Name
                        if ($key -match '^[^/]+/(?<key>.*?)/[^/]+$') {
                            # If the value of $property.Key is in the format 'device:0:1/KeyName/usually-a-guid', we just want the KeyName value in the middle
                            $key = $Matches.key
                        }
                        $obj = [pscustomobject]@{
                            RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                            Hardware        = $hw.Name
                            Microphone      = $device.Name
                            Channel         = $device.Channel

                            Setting         = $key
                            Value           = $property.Value
                            DisplayValue    = if ($property.ValueType -eq 'Enum' -and $displayValue -ne $property.Value) { $displayValue } else { $null }
                        }
                        $null = $obj | Export-Excel @excelParams -WorksheetName MicrophoneStreamSettings -TableName MicrophoneStreamSettingsList
                    }

                    Write-Verbose "Retrieving event properties for $($device.Name)"
                    $obj = [ordered]@{
                        RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                        Hardware        = $hw.Name
                        Microphone      = $device.Name
                    }
                    $null = $device | Export-DeviceEventConfig | ForEach-Object {
                        $eventInfo = $_
                        $obj.EventName = $eventInfo.Event
                        $obj.Used = $eventInfo.Used
                        $obj.Enabled = $eventInfo.Enabled
                        $obj.EventIndex = $eventInfo.EventIndex
                        $obj.IndexName = $eventInfo.IndexName
                        [pscustomobject]$obj | Export-Excel @excelParams -WorksheetName MicrophoneEvents -TableName MicrophoneEventsList
                    }

                    Write-Verbose "Retrieving device groups for $($device.Name)"
                    if ($deviceGroups.ContainsKey($device.Id)) {
                        $null = $deviceGroups[$device.Id] | Where-Object { $null -ne $_ } | ForEach-Object {
                            [pscustomobject]@{
                                RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                                Hardware        = $hw.Name
                                Microphone      = $device.Name
                                Group           = $_
                            }
                        } | Export-Excel @excelParams -WorksheetName MicrophoneGroups -TableName MicrophoneGroupsList
                    }
                }
            }

            if ('Speaker' -in $IncludedDevices) {
                $hw | Get-VmsSpeaker -EnableFilter $EnableFilter | ForEach-Object {
                    $progress.CurrentOperation = '{0} "{1}"' -f [VideoOS.Platform.Proxy.ConfigApi.ConfigurationItemPath]::new($_.Path).ItemType, $_.Name
                    Write-Progress @progress
                    $device = $_
                    if (($EnableFilter -eq 'Enabled' -and -not $device.Enabled) -or ($EnableFilter -eq 'Disabled' -and $device.Enabled)) {
                        Write-Verbose "Skipping speaker $($device.Name) due to the EnableFilter value of $EnableFilter"
                        return
                    }
                    Write-Verbose "Retrieving speaker properties for $($device.Name)"
                    $null = $device | Get-DevicePropertyList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName Speakers -TableName SpeakersList }

                    Write-Verbose "Retrieving general setting properties for $($device.Name)"
                    $null = $device | Get-GeneralSettingList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName SpeakerGeneralSettings -TableName SpeakerGeneralSettingsList }

                    Write-Verbose "Retrieving event properties for $($device.Name)"
                    $obj = [ordered]@{
                        RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                        Hardware        = $hw.Name
                        Speaker         = $device.Name
                    }
                    $null = $device | Export-DeviceEventConfig | ForEach-Object {
                        $eventInfo = $_
                        $obj.EventName = $eventInfo.Event
                        $obj.Used = $eventInfo.Used
                        $obj.Enabled = $eventInfo.Enabled
                        $obj.EventIndex = $eventInfo.EventIndex
                        $obj.IndexName = $eventInfo.IndexName
                        [pscustomobject]$obj | Export-Excel @excelParams -WorksheetName SpeakerEvents -TableName SpeakerEventsList
                    }

                    Write-Verbose "Retrieving device groups for $($device.Name)"
                    if ($deviceGroups.ContainsKey($device.Id)) {
                        $null = $deviceGroups[$device.Id] | Where-Object { $null -ne $_ } | ForEach-Object {
                            [pscustomobject]@{
                                RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                                Hardware        = $hw.Name
                                Speaker         = $device.Name
                                Group           = $_
                            }
                        } | Export-Excel @excelParams -WorksheetName SpeakerGroups -TableName SpeakerGroupsList
                    }
                }
            }

            if ('Metadata' -in $IncludedDevices) {
                $hw | Get-VmsMetadata -EnableFilter $EnableFilter | ForEach-Object {
                    $progress.CurrentOperation = '{0} "{1}"' -f [VideoOS.Platform.Proxy.ConfigApi.ConfigurationItemPath]::new($_.Path).ItemType, $_.Name
                    Write-Progress @progress
                    $device = $_
                    if (($EnableFilter -eq 'Enabled' -and -not $device.Enabled) -or ($EnableFilter -eq 'Disabled' -and $device.Enabled)) {
                        Write-Verbose "Skipping metadata $($device.Name) due to the EnableFilter value of $EnableFilter"
                        return
                    }
                    Write-Verbose "Retrieving metadata properties for $($device.Name)"
                    $null = $device | Get-DevicePropertyList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName Metadata -TableName MetadataList }

                    Write-Verbose "Retrieving metadata general settings for $($device.Name)"
                    $null = $device | Get-GeneralSettingList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName MetadataGeneralSettings -TableName MetadataGeneralSettingsList }

                    Write-Verbose "Retrieving device groups for $($device.Name)"
                    if ($deviceGroups.ContainsKey($device.Id)) {
                        $null = $deviceGroups[$device.Id] | Where-Object { $null -ne $_ } | ForEach-Object {
                            [pscustomobject]@{
                                RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                                Hardware        = $hw.Name
                                Metadata        = $device.Name
                                Group           = $_
                            }
                        } | Export-Excel @excelParams -WorksheetName MetadataGroups -TableName MetadataGroupsList
                    }
                }
            }

            if ('Input' -in $IncludedDevices) {
                $hw | Get-VmsInput -EnableFilter $EnableFilter | ForEach-Object {
                    $progress.CurrentOperation = '{0} "{1}"' -f [VideoOS.Platform.Proxy.ConfigApi.ConfigurationItemPath]::new($_.Path).ItemType, $_.Name
                    Write-Progress @progress
                    $device = $_
                    if (($EnableFilter -eq 'Enabled' -and -not $device.Enabled) -or ($EnableFilter -eq 'Disabled' -and $device.Enabled)) {
                        Write-Verbose "Skipping input $($device.Name) due to the EnableFilter value of $EnableFilter"
                        return
                    }
                    Write-Verbose "Retrieving input properties for $($device.Name)"
                    $null = $device | Get-DevicePropertyList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName Inputs -TableName InputsList }

                    Write-Verbose "Retrieving input general settings for $($device.Name)"
                    $null = $device | Get-GeneralSettingList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName InputGeneralSettings -TableName InputGeneralSettingsList }

                    Write-Verbose "Retrieving event properties for $($device.Name)"
                    $obj = [ordered]@{
                        RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                        Hardware        = $hw.Name
                        Input           = $device.Name
                    }
                    $null = $device | Export-DeviceEventConfig | ForEach-Object {
                        $eventInfo = $_
                        $obj.EventName = $eventInfo.Event
                        $obj.Used = $eventInfo.Used
                        $obj.Enabled = $eventInfo.Enabled
                        $obj.EventIndex = $eventInfo.EventIndex
                        $obj.IndexName = $eventInfo.IndexName
                        [pscustomobject]$obj | Export-Excel @excelParams -WorksheetName InputEvents -TableName InputEventsList
                    }

                    Write-Verbose "Retrieving device groups for $($device.Name)"
                    if ($deviceGroups.ContainsKey($device.Id)) {
                        $null = $deviceGroups[$device.Id] | Where-Object { $null -ne $_ } | ForEach-Object {
                            [pscustomobject]@{
                                RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                                Hardware        = $hw.Name
                                Input           = $device.Name
                                Group           = $_
                            }
                        } | Export-Excel @excelParams -WorksheetName InputGroups -TableName InputGroupsList
                    }
                }
            }

            if ('Output' -in $IncludedDevices) {
                $hw | Get-VmsOutput -EnableFilter $EnableFilter | ForEach-Object {
                    $progress.CurrentOperation = '{0} "{1}"' -f [VideoOS.Platform.Proxy.ConfigApi.ConfigurationItemPath]::new($_.Path).ItemType, $_.Name
                    Write-Progress @progress
                    $device = $_
                    if (($EnableFilter -eq 'Enabled' -and -not $device.Enabled) -or ($EnableFilter -eq 'Disabled' -and $device.Enabled)) {
                        Write-Verbose "Skipping output $($device.Name) due to the EnableFilter value of $EnableFilter"
                        return
                    }
                    Write-Verbose "Retrieving output properties for $($device.Name)"
                    $null = $device | Get-DevicePropertyList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName Outputs -TableName OutputsList }

                    Write-Verbose "Retrieving output general settings for $($device.Name)"
                    $null = $device | Get-GeneralSettingList | ForEach-Object { $_ | Export-Excel @excelParams -WorksheetName OutputGeneralSettings -TableName OutputGeneralSettingsList }

                    Write-Verbose "Retrieving device groups for $($device.Name)"
                    if ($deviceGroups.ContainsKey($device.Id)) {
                        $null = $deviceGroups[$device.Id] | Where-Object { $null -ne $_ } | ForEach-Object {
                            [pscustomobject]@{
                                RecordingServer = $recorderMap[$hw.ParentItemPath].Name
                                Hardware        = $hw.Name
                                Output          = $device.Name
                                Group           = $_
                            }
                        } | Export-Excel @excelParams -WorksheetName OutputGroups -TableName OutputGroupsList
                    }
                }
            }
        }
        $progress.PercentComplete = 100
        $progress.Completed = $true
        Write-Progress @progress
    }

    end {
        $excelPackage.Workbook.Worksheets.Name | ForEach-Object {
            if ($null -eq $excelPackage.Workbook.Worksheets[$_].GetValue(1, 1)) {
                $excelPackage.Workbook.Worksheets.Delete($_)
            }
        }
        $excelPackage | Close-ExcelPackage
    }
}

function Import-VmsHardwareExcel {
    <#
    .SYNOPSIS
    Imports hardware configuration from an Excel .XLSX document and adds and
    optionally updates hardware based.

    .DESCRIPTION
    The `Import-VmsHardwareExcel` cmdlet accepts a path to an existing Excel
    .XLSX document, and imports the hardware configuration. The cmdlet can add
    new devices and update the settings of existing devices if the values in
    the Excel document differ from the live values.

    Depending on the content of the Excel document, the settings imported can
    include hardware, general settings, cameras, microphones, speakers, inputs,
    outputs, metadata, and the corresponding general settings, settings for
    streams, recording, events, motion, and more.

    The format of the Excel document, and the valid values for various settings
    is challenging to document. The best way to perform a successful import is
    to add and configure a representative sample of devices, and then use
    `Export-VmsHardwareExcel` to generate a configuration export. You can then
    use the export as a reference to build a document to import.

    .PARAMETER Path
    Specifies a path to an existing Excel document in .XLSX format. While the
    `ImportExcel` module supports reading from password protected files, this
    has not been extended to this cmdlet. If no path is provided, an open-file
    dialog will be shown.

    .PARAMETER UpdateExisting
    If hardware defined in the Excel document is already added, it will not be
    modified by default. If you wish to update the settings for existing
    hardware during an import, this switch can be used.

    .EXAMPLE
    Import-VmsHardwareExcel -Path ~\Desktop\hardware.xlsx -Verbose

    Imports the hardware.xlsx file on the current user's desktop. If any cameras
    in the Excel document are already added, they will be ignored and their
    settings will not be modified if they have drifted from the configuration
    defined in the document.

    .EXAMPLE
    Import-VmsHardwareExcel -Path ~\Desktop\hardware.xlsx -UpdateExisting -Verbose

    Imports the hardware.xlsx file on the current user's desktop. If any cameras
    in the Excel document are already added, they will be updated to reflect the
    configuration defined in the document.

    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Path,

        [Parameter()]
        [VideoOS.Platform.ConfigurationItems.RecordingServer]
        $RecordingServer,

        [Parameter()]
        [pscredential[]]
        $Credential,

        [Parameter()]
        [switch]
        $UpdateExisting
    )

    begin {
        if ($null -eq (Get-VmsManagementServer -ErrorAction 'SilentlyContinue')) {
            Connect-Vms -ShowDialog -AcceptEula -ErrorAction Stop
        }
        if ([string]::IsNullOrWhiteSpace($Path)) {
            $Path = Show-FileDialog -OpenFile
        }
        try {
            $excelPackage = Open-ExcelPackage -Path $Path
            $worksheets = $excelPackage.Workbook.Worksheets.Name
            $data = @{
                Hardware                  = [list[pscustomobject]]::new()
                HardwareGeneralSettings   = [list[pscustomobject]]::new()
                HardwarePtzSettings       = [list[pscustomobject]]::new()
                HardwareEvents            = [list[pscustomobject]]::new()
                Cameras                   = [list[pscustomobject]]::new()
                CameraGeneralSettings     = [list[pscustomobject]]::new()
                CameraStreams             = [list[pscustomobject]]::new()
                CameraStreamSettings      = [list[pscustomobject]]::new()
                CameraPtzPresets          = [list[pscustomobject]]::new()
                CameraPtzPatrols          = [list[pscustomobject]]::new()
                CameraPtzPatrolPresets    = [list[pscustomobject]]::new()
                CameraRelatedDevices      = [list[pscustomobject]]::new()
                CameraEvents              = [list[pscustomobject]]::new()
                CameraGroups              = [list[pscustomobject]]::new()
                Microphones               = [list[pscustomobject]]::new()
                MicrophoneGeneralSettings = [list[pscustomobject]]::new()
                MicrophoneStreamSettings  = [list[pscustomobject]]::new()
                MicrophoneEvents          = [list[pscustomobject]]::new()
                MicrophoneGroups          = [list[pscustomobject]]::new()
                Speakers                  = [list[pscustomobject]]::new()
                SpeakerGeneralSettings    = [list[pscustomobject]]::new()
                SpeakerEvents             = [list[pscustomobject]]::new()
                SpeakerGroups             = [list[pscustomobject]]::new()
                Metadata                  = [list[pscustomobject]]::new()
                MetadataGeneralSettings   = [list[pscustomobject]]::new()
                MetadataGroups            = [list[pscustomobject]]::new()
                Inputs                    = [list[pscustomobject]]::new()
                InputGeneralSettings      = [list[pscustomobject]]::new()
                InputEvents               = [list[pscustomobject]]::new()
                InputGroups               = [list[pscustomobject]]::new()
                Outputs                   = [list[pscustomobject]]::new()
                OutputGeneralSettings     = [list[pscustomobject]]::new()
                OutputGroups              = [list[pscustomobject]]::new()
            }
            foreach ($key in $data.Keys) {
                if ($key -in $worksheets) {
                    if ($excelPackage.Workbook.Worksheets[$key].GetValue(1, 1)) {
                        Import-Excel -ExcelPackage $excelPackage -WorksheetName $key | ForEach-Object {
                            if ($null -ne $_.RecordingServer -and $PSBoundParameters.ContainsKey('RecordingServer')) {
                                $_.RecordingServer = $RecordingServer.Name
                            }
                            $data[$key].Add($_)
                        }
                    } else {
                        Write-Verbose "Ignoring worksheet '$key' because the value at 1,1 is null."
                    }
                }
            }
        } finally {
            if ($excelPackage) {
                $excelPackage | Close-ExcelPackage -NoSave
            }
        }
    }

    process {
        if ($data.Hardware.Count -eq 0) {
            Write-Error 'No hardware entries found in the Hardware worksheet.'
            return
        }

        $totalRows = $data.Hardware.Count
        $processedRows = 0
        $progressParams = @{
            Activity         = 'Importing hardware configuration from {0}' -f $Path
            Id               = 42
            PercentComplete  = 0
            CurrentOperation = 'Preparing'
        }
        Write-Progress @progressParams

        $recorders = @{}
        $existingHardware = @{}
        foreach ($rec in Get-VmsRecordingServer) {
            $recorders[$rec.Name] = $rec
            $existingHardware[$rec.Name] = @{}
            foreach ($hw in $rec | Get-VmsHardware) {
                if ($uri = $hw.Address -as [uri]) {
                    $hostAndPort = $uri.GetComponents([UriComponents]::HostAndPort, [uriformat]::Unescaped)
                    $existingHardware[$rec.Name][$hostAndPort] = $hw
                }
            }
        }

        foreach ($row in $data.Hardware | Sort-Object RecordingServer) {
            $progressParams.PercentComplete = [math]::Round(($processedRows++) / $totalRows * 100)
            $progressParams.CurrentOperation = '{0} ({1})' -f $row.Name, $row.Address
            Write-Progress @progressParams
            try {
                $recorder = if ($row.RecordingServer) { $recorders[$row.RecordingServer] } else { $null }
                if ($null -eq $recorder) {
                    Write-Warning "Recording server '$($row.RecordingServer)' not found. Skipping hardware '$($row.Name)' ($($row.Address))."
                    continue
                }


                $params = @{
                    HardwareAddress = $row.Address -as [uri]
                    Credential      = [collections.generic.list[pscredential]]::new()
                    DriverNumber    = $row.DriverNumber -as [int]
                    RecordingServer = $recorder
                    ErrorAction     = 'Stop'
                }

                if ($row.UserName -and $row.Password) {
                    $params.Credential.Add([pscredential]::new($row.UserName, ($row.Password | ConvertTo-SecureString -AsPlainText -Force)))
                }
                foreach ($pscredential in $Credential){
                    $params.Credential.Add($pscredential)
                }

                if (-not $params.HardwareAddress -or -not $params.HardwareAddress.IsAbsoluteUri) {
                    Write-Warning "Hardware '$($row.Name)' must have a valid address in the Address column. The value '$($row.Address)' is not a valid absolute URI. Example: http://192.168.1.101"
                    continue
                }

                $hostAndPort = $params.HardwareAddress.GetComponents([UriComponents]::HostAndPort, [uriformat]::Unescaped)
                if (($hardware = $existingHardware[$row.RecordingServer][$hostAndPort])) {
                    if (-not $UpdateExisting) {
                        Write-Verbose "Skipping the hardware at $($params.HardwareAddress) because it is already added to $($recorder.Name). To Update existing hardware/devices, use the 'UpdateExisting' switch."
                        continue
                    }
                } else {
                    if (-not $params.DriverNumber) {
                        $scanParams = @{
                            RecordingServer = $recorder
                            Address         = $params.HardwareAddress
                        }
                        if ($row.DriverGroup) {
                            $scanParams.DriverFamily = $row.DriverGroup
                        }
                        if ($params.Credential) {
                            $scanParams.Credential = $params.Credential
                        } else {
                            $scanParams.UseDefaultCredentials
                        }
                        Write-Verbose "Scanning hardware at $($row.Address) for driver discovery"
                        $scans = Start-VmsHardwareScan @scanParams
                        $scan = if ($null -eq ($scans | Where-Object HardwareScanValidated)) {
                            $scans | Select-Object -Last 1
                        } else {
                            $scans | Where-Object HardwareScanValidated | Select-Object -First 1
                        }
                        if ($scan.HardwareScanValidated) {
                            $params.Remove('DriverNumber')
                            $params.HardwareDriverPath = $scan.HardwareDriverPath
                            $params.Credential = [pscredential]::new($scan.UserName, ($scan.Password | ConvertTo-SecureString -AsPlainText -Force))
                        } else {
                            Write-Error -Message "Hardware scan failed for '$($row.Name)' ($($params.HardwareAddress)). ErrorText: '$($scan.ErrorText)'" -TargetObject $scan
                            continue
                        }
                    }
                    $credentials = $params.Credential
                    foreach ($hwCredential in $credentials) {
                        try {
                            $params.Credential = $hwCredential
                            $hardware = Add-VmsHardware @params
                        } catch {
                            Write-Error -ErrorRecord $_
                        }
                    }
                }
                $setHwParams = @{
                    Name        = if ($row.Name) { $row.Name } else { $hardware.Name }
                    Enabled     = $script:Truthy.IsMatch($row.Enabled)
                    Description = $row.Description
                    Verbose     = $VerbosePreference
                }
                $hardware | Set-VmsHardware @setHwParams

                $settings = $data.HardwareGeneralSettings | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name }
                if ($settings) {
                    Import-GeneralSettingList -Device $hardware -Settings $settings
                }

                $settings = $data.HardwarePtzSettings | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name } | Sort-Object Channel
                if ($settings) {
                    if ($hardware.HardwarePtzSettingsFolder.HardwarePtzSettings.Count) {
                        try {
                            $ptzSettings = $hardware.HardwarePtzSettingsFolder.HardwarePtzSettings
                            $channel = 0
                            foreach ($ptzChannel in $ptzSettings.HardwarePtzDeviceSettingChildItems) {
                                if ($settings.Count -lt ($channel + 1)) {
                                    Write-Warning "No HardwarePtzSettings available for channel $channel"
                                    continue
                                }
                                'PTZEnabled', 'PTZDeviceID', 'PTZCOMPort', 'PTZProtocol' | ForEach-Object {
                                    if ([string]::IsNullOrWhiteSpace($settings[$channel])) {
                                        Write-Warning "The supplied value for HardwarePtzSetting '$_' for $($hardware.Name) channel $channel is null or empty"
                                        return
                                    }
                                    if ($ptzChannel.Properties.GetValue($_) -cne $settings[$channel].$_) {
                                        $ptzChannel.Properties.SetValue($_, $settings[$channel].$_)
                                    }
                                }
                                
                                $channel += 1
                            }
                            $ptzSettings.Save()
                        } catch {
                            throw
                        }
                    } else {
                        Write-Warning "Unable to import HardwarePtzSettings for '$($hardware.Name)'. It may not be supported on the current VMS version or on this device."
                    }
                }

                $settings = $data.HardwareEvents | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name }
                if ($settings) {
                    Import-DeviceEventConfig -Device $hardware -Settings $settings
                }


                $cameraRows = $data.Cameras | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name }
                if ($cameraRows) {
                    Write-Verbose "Updating camera properties for $($hardware.Name)"
                    $hardware | Get-VmsCamera -EnableFilter All | Where-Object Channel -In $cameraRows.Channel | ForEach-Object {
                        $camera = $_

                        Import-DevicePropertyList -Device $_ -Settings ($cameraRows | Where-Object Channel -EQ $_.Channel | Select-Object -First 1)

                        $generalSettings = $data.CameraGeneralSettings | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Camera -eq $camera.Name }
                        if ($generalSettings) {
                            Import-GeneralSettingList -Device $_ -Settings $generalSettings
                        }

                        $eventSettings = $data.CameraEvents | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Camera -eq $camera.Name }
                        if ($eventSettings) {
                            Import-DeviceEventConfig -Device $camera -Settings $eventSettings
                        }

                        $data.CameraStreams | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Camera -eq $camera.Name } | Sort-Object Channel | ForEach-Object {
                            $streamRow = $_
                            $stream = $camera | Get-VmsCameraStream -Name $streamRow.Name -ErrorAction SilentlyContinue
                            if ($stream) {
                                $streamParams = @{}
                                if (-not [string]::IsNullOrWhiteSpace($streamRow.DisplayName)) {
                                    $streamParams.DisplayName = $streamRow.DisplayName
                                }
                                if ($streamRow.LiveMode -in 'Always', 'Never', 'WhenNeeded') {
                                    $streamParams.LiveMode = $streamRow.LiveMode
                                }
                                if ($script:TruthyFalsey.IsMatch($streamRow.LiveDefault)) {
                                    $streamParams.LiveDefault = $script:Truthy.IsMatch($streamRow.LiveDefault)
                                }
                                if ($script:TruthyFalsey.IsMatch($streamRow.PlaybackDefault)) {
                                    if (Test-VmsLicensedFeature -Name MultistreamRecording) {
                                        $streamParams.PlaybackDefault = $script:Truthy.IsMatch($streamRow.PlaybackDefault)
                                    } else {
                                        Write-Verbose "PlaybackDefault cannot be set because your VMS version does not include the MultistreamRecording feature."
                                    }
                                }
                                if ($streamRow.RecordingTrack -in 'Primary', 'Secondary', 'None') {
                                    $streamParams.RecordingTrack = $streamRow.RecordingTrack
                                }
                                if ($script:TruthyFalsey.IsMatch($streamRow.UseEdge)) {
                                    $streamParams.UseEdge = $script:Truthy.IsMatch($streamRow.UseEdge)
                                }
                                if ($streamParams.Count -gt 0) {
                                    $streamParams.Verbose = $VerbosePreference
                                    $stream | Set-VmsCameraStream @streamParams
                                }
                            } else {
                                Write-Warning "No stream found on $($camera.Name) with the name '$($streamRow.Name)'"
                            }
                        }

                        $data.CameraStreamSettings | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Camera -eq $camera.Name -and $_.Setting -and $_.Value } | Group-Object Stream | ForEach-Object {
                            $streamName = $_.Name
                            $streamSettings = @{}
                            $_.Group | ForEach-Object { $streamSettings[$_.Setting] = $_.Value }
                            $stream = $camera | Get-VmsCameraStream -Name $streamName -ErrorAction Ignore
                            if ($stream) {
                                $stream | Set-VmsCameraStream -Settings $streamSettings -Verbose:($VerbosePreference -eq 'Continue' )
                            } else {
                                Write-Warning "No stream found on $($camera.Name) with the name '$($streamRow.Name)'"
                            }
                        }

                        $data.CameraPtzPresets | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Camera -eq $camera.Name } | ForEach-Object {
                            $ptzPresetRow = $_
                            if ($ptzPresetRow.Name -notin $camera.PtzPresetFolder.PtzPresets.Name) {
                                $newPtzPreset = $camera.PtzPresetFolder.AddPtzPreset($ptzPresetRow.Name, $ptzPresetRow.Description, $ptzPresetRow.Pan, $ptzPresetRow.Tilt, $ptzPresetRow.Zoom)
                                if ($ptzPresetRow.DefaultPreset -eq $true) {
                                    $null = $camera.PtzPresetFolder.DefaultPtzPreset($newPtzPreset.Path)
                                }
                            }
                        }

                        $data.CameraPtzPatrols | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Camera -eq $camera.Name } | ForEach-Object {
                            $ptzPatrolRow = $_
                            if ($ptzPatrolRow.Name -notin $camera.PatrollingProfileFolder.PatrollingProfiles.Name) {
                                $endPresetId = ($camera.PtzPresetFolder.PtzPresets | Where-Object { $_.Name -eq $ptzPatrolRow.EndPresetName }).Id
                                $newPtzPatrol = $camera.PatrollingProfileFolder.AddPatrollingProfile($ptzPatrolRow.Name, $ptzPatrolRow.Description, $ptzPatrolRow.CustomizeTransitions, $ptzPatrolRow.InitSpeed, $ptzPatrolRow.InitTransitionTime, $endPresetId, $ptzPatrolRow.EndSpeed, $ptzPatrolRow.EndTransitionTime)
                                $newPtzPatrol = $camera.PatrollingProfileFolder.PatrollingProfiles | Where-Object { $_.Path -eq $newPtzPatrol.Path }

                                $index = 0
                                $data.CameraPtzPatrolPresets | Where-Object { $_.Patrol -eq $newPtzPatrol.Name } | ForEach-Object {
                                    $ptzPatrolPresetRow = $_
                                    $patrolPresetId = ($camera.PtzPresetFolder.PtzPresets | Where-Object { $_.Name -eq $ptzPatrolPresetRow.PresetName }).Id
                                    $null = $newPtzPatrol.AddPatrollingEntry($ptzPatrolPresetRow.Order, $patrolPresetId, $ptzPatrolPresetRow.WaitTime)

                                    $patrol = Get-ConfigurationItem -Path "PatrollingProfile[$($newPtzPatrol.Id)]"
                                    if ($newPtzPatrol.CustomizeTransitions) {
                                        ($patrol.Children[$index].Properties | Where-Object { $_.Key -eq 'Speed' }).Value = $ptzPatrolPresetRow.Speed
                                        ($patrol.Children[$index].Properties | Where-Object { $_.Key -eq 'TransitionTime' }).Value = $ptzPatrolPresetRow.TransitionTime
                                    }
                                    ### TODO: Refactor this section so Set-ConfigurationItem only needs to be called after the entire Patrol object has been updated
                                    $null = Set-ConfigurationItem -ConfigurationItem $patrol
                                    $index++
                                }
                            }
                        }

                        $data.CameraGroups | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Camera -eq $camera.Name } | ForEach-Object {
                            # Device may already be added to the destination device group. If so, SilentlyContinue will hide the ArgumentMIPException error.
                            Write-Verbose "Adding $($camera.Name) to device group $($_.Group)"
                            New-VmsDeviceGroup -Type Camera -Path $_.Group | Add-VmsDeviceGroupMember -Device $camera -ErrorAction SilentlyContinue
                        }
                    }
                } else {
                    Write-Verbose "No cameras to configure for $($hardware.Name)"
                }

                $rows = $data.Microphones | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name }
                if ($rows) {
                    Write-Verbose "Updating microphone properties for $($hardware.Name)"
                    $hardware | Get-VmsMicrophone -EnableFilter All | Where-Object Channel -In $rows.Channel | ForEach-Object {
                        $device = $_

                        Import-DevicePropertyList -Device $device -Settings ($rows | Where-Object Channel -EQ $device.Channel | Select-Object -First 1)

                        $generalSettings = $data.MicrophoneGeneralSettings | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Microphone -eq $device.Name }
                        if ($generalSettings) {
                            Import-GeneralSettingList -Device $device -Settings $generalSettings
                        }

                        $eventSettings = $data.MicrophoneEvents | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Microphone -eq $device.Name }
                        if ($eventSettings) {
                            Import-DeviceEventConfig -Device $device -Settings $eventSettings
                        }

                        $data.MicrophoneGroups | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Microphone -eq $device.Name } | ForEach-Object {
                            # Device may already be added to the destination device group. If so, SilentlyContinue will hide the ArgumentMIPException error.
                            Write-Verbose "Adding $($device.Name) to device group $($_.Group)"
                            New-VmsDeviceGroup -Type Microphone -Path $_.Group | Add-VmsDeviceGroupMember -Device $device -ErrorAction SilentlyContinue
                        }
                    }
                } else {
                    Write-Verbose "No microphones to configure for $($hardware.Name)"
                }


                $rows = $data.Speakers | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name }
                if ($rows) {
                    Write-Verbose "Updating speaker properties for $($hardware.Name)"
                    $hardware | Get-VmsSpeaker -EnableFilter All | Where-Object Channel -In $rows.Channel | ForEach-Object {
                        $device = $_

                        Import-DevicePropertyList -Device $device -Settings ($rows | Where-Object Channel -EQ $device.Channel | Select-Object -First 1)

                        $generalSettings = $data.SpeakerGeneralSettings | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Speaker -eq $device.Name }
                        if ($generalSettings) {
                            Import-GeneralSettingList -Device $device -Settings $generalSettings
                        }

                        $data.SpeakerGroups | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Speaker -eq $device.Name } | ForEach-Object {
                            # Device may already be added to the destination device group. If so, SilentlyContinue will hide the ArgumentMIPException error.
                            Write-Verbose "Adding $($device.Name) to device group $($_.Group)"
                            New-VmsDeviceGroup -Type Speaker -Path $_.Group | Add-VmsDeviceGroupMember -Device $device -ErrorAction SilentlyContinue
                        }
                    }
                } else {
                    Write-Verbose "No speakers to configure for $($hardware.Name)"
                }


                $rows = $data.Metadata | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name }
                if ($rows) {
                    Write-Verbose "Updating metadata properties for $($hardware.Name)"
                    $hardware | Get-VmsMetadata -EnableFilter All | Where-Object Channel -In $rows.Channel | ForEach-Object {
                        $device = $_

                        Import-DevicePropertyList -Device $device -Settings ($rows | Where-Object Channel -EQ $device.Channel | Select-Object -First 1)

                        $generalSettings = $data.MetadataGeneralSettings | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Metadata -eq $device.Name }
                        if ($generalSettings) {
                            Import-GeneralSettingList -Device $device -Settings $generalSettings
                        }

                        $data.MetadataGroups | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Metadata -eq $device.Name } | ForEach-Object {
                            # Device may already be added to the destination device group. If so, SilentlyContinue will hide the ArgumentMIPException error.
                            Write-Verbose "Adding $($device.Name) to device group $($_.Group)"
                            New-VmsDeviceGroup -Type Metadata -Path $_.Group | Add-VmsDeviceGroupMember -Device $device -ErrorAction SilentlyContinue
                        }
                    }
                } else {
                    Write-Verbose "No metadata to configure for $($hardware.Name)"
                }


                $rows = $data.Inputs | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name }
                if ($rows) {
                    Write-Verbose "Updating IO input properties for $($hardware.Name)"
                    $hardware | Get-VmsInput -EnableFilter All | Where-Object Channel -In $rows.Channel | ForEach-Object {
                        $device = $_

                        Import-DevicePropertyList -Device $device -Settings ($rows | Where-Object Channel -EQ $device.Channel | Select-Object -First 1)

                        $generalSettings = $data.InputGeneralSettings | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.InputEvent -eq $device.Name }
                        if ($generalSettings) {
                            Import-GeneralSettingList -Device $device -Settings $generalSettings
                        }

                        $data.InputGroups | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Input -eq $device.Name } | ForEach-Object {
                            # Device may already be added to the destination device group. If so, SilentlyContinue will hide the ArgumentMIPException error.
                            Write-Verbose "Adding $($device.Name) to device group $($_.Group)"
                            New-VmsDeviceGroup -Type Input -Path $_.Group | Add-VmsDeviceGroupMember -Device $device -ErrorAction SilentlyContinue
                        }
                    }
                } else {
                    Write-Verbose "No inputs to configure for $($hardware.Name)"
                }

                $rows = $data.Outputs | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name }
                if ($rows) {
                    Write-Verbose "Updating IO output properties for $($hardware.Name)"
                    $hardware | Get-VmsOutput -EnableFilter All | Where-Object Channel -In $rows.Channel | ForEach-Object {
                        $device = $_

                        Import-DevicePropertyList -Device $device -Settings ($rows | Where-Object Channel -EQ $device.Channel | Select-Object -First 1)

                        $generalSettings = $data.OutputGeneralSettings | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Output -eq $device.Name }
                        if ($generalSettings) {
                            Import-GeneralSettingList -Device $device -Settings $generalSettings
                        }

                        $data.OutputGroups | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Output -eq $device.Name } | ForEach-Object {
                            # Device may already be added to the destination device group. If so, SilentlyContinue will hide the ArgumentMIPException error.
                            Write-Verbose "Adding $($device.Name) to device group $($_.Group)"
                            New-VmsDeviceGroup -Type Output -Path $_.Group | Add-VmsDeviceGroupMember -Device $device -ErrorAction SilentlyContinue
                        }
                    }
                } else {
                    Write-Verbose "No outputs to configure for $($hardware.Name)"
                }
            } catch {
                Write-Error -ErrorRecord $_
            }
        }
        $progressParams.PercentComplete = 100
        $progressParams.Completed = $true
        Write-Progress @progressParams

        Clear-VmsCache

        $totalRows = $data.Hardware.Count
        $processedRows = 0
        $progressParams = @{
            Activity        = 'Configuring related devices'
            Id              = 43
            PercentComplete = 0
        }
        Write-Progress @progressParams

        foreach ($row in $data.Hardware | Sort-Object RecordingServer) {
            $progressParams.PercentComplete = [math]::Round(($processedRows++) / $totalRows * 100)
            $progressParams.CurrentOperation = '{0} ({1})' -f $row.Name, $row.Address
            Write-Progress @progressParams

            $recorder = if ($row.RecordingServer) { $recorders[$row.RecordingServer] } else { $null }
            if ($null -eq $recorder) {
                continue
            }

            $params = @{
                Name            = $row.Name
                HardwareAddress = $row.Address -as [uri]
                RecordingServer = $recorder
                ErrorAction     = 'Stop'
            }

            if ([string]::IsNullOrWhiteSpace($params.Name)) {
                $params.Remove('Name')
            }

            $hostAndPort = $params.HardwareAddress.GetComponents([UriComponents]::HostAndPort, [uriformat]::Unescaped)
            if (($hardware = $existingHardware[$row.RecordingServer][$hostAndPort])) {
                if (-not $UpdateExisting) {
                    Write-Verbose "Skipping the hardware at $($params.HardwareAddress) because it is already added to $($recorder.Name). To Update existing hardware/devices, use the 'UpdateExisting' switch."
                    continue
                }
            }

            $hardware = Get-VmsHardware -Name $row.Name
            $cameraRows = $data.Cameras | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name }
            if ($cameraRows) {
                foreach ($camera in $hardware | Get-VmsCamera -EnableFilter All) {
                    $relatedDevicesString = $null
                    $data.CameraRelatedDevices | Where-Object { $_.RecordingServer -eq $recorder.Name -and $_.Hardware -eq $hardware.Name -and $_.Camera -eq $camera.Name -and $_.Channel -eq $camera.Channel } | ForEach-Object {
                        $relatedDevicesRow = $_
                        if ([string]::IsNullOrEmpty($relatedDevicesString)) {
                            $relatedRec = $recorders[$relatedDevicesRow.RelatedRecordingServerName]
                            $relatedHW = Get-VmsHardware -RecordingServer $relatedRec | Where-Object Address -EQ $relatedDevicesRow.RelatedHardwareAddress
                            switch ($relatedDevicesRow.RelatedDeviceType) {
                                Metadata { $relatedDeviceItem = Get-VmsMetadata -EnableFilter All -Hardware $relatedHW -Channel $relatedDevicesRow.Channel }
                                Microphone { $relatedDeviceItem = Get-VmsMicrophone -EnableFilter All -Hardware $relatedHW -Channel $relatedDevicesRow.Channel }
                                Speaker { $relatedDeviceItem = Get-VmsSpeaker -EnableFilter All -Hardware $relatedHW -Channel $relatedDevicesRow.Channel }
                            }
                            [string]$relatedDevicesString = $relatedDeviceItem.Path
                        } else {
                            $relatedRec = $recorders[$relatedDevicesRow.RelatedRecordingServerName]
                            $relatedHW = Get-VmsHardware -RecordingServer $relatedRec | Where-Object Address -EQ $relatedDevicesRow.RelatedHardwareAddress
                            switch ($relatedDevicesRow.RelatedDeviceType) {
                                Metadata { $relatedDeviceItem = Get-VmsMetadata -EnableFilter All -Hardware $relatedHW -Channel $relatedDevicesRow.Channel }
                                Microphone { $relatedDeviceItem = Get-VmsMicrophone -EnableFilter All -Hardware $relatedHW -Channel $relatedDevicesRow.Channel }
                                Speaker { $relatedDeviceItem = Get-VmsSpeaker -EnableFilter All -Hardware $relatedHW -Channel $relatedDevicesRow.Channel }
                            }
                            [string]$relatedDevicesString += ",$($relatedDeviceItem.Path)"
                        }
                    }
                    $clientSettingsItem = $camera.ClientSettingsFolder.ClientSettings[0]
                    $clientSettingsItem.Related = $relatedDevicesString
                    $clientSettingsItem.Save()
                }
            }
        }
        $progressParams.PercentComplete = 100
        $progressParams.Completed = $true
        Write-Progress @progressParams
    }
}
