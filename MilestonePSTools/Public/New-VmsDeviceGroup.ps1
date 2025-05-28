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

function New-VmsDeviceGroup {
    [CmdletBinding()]
    [Alias('Add-DeviceGroup')]
    [OutputType([VideoOS.Platform.ConfigurationItems.IConfigurationItem])]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipeline, Position = 0, ParameterSetName = 'ByName')]
        [ValidateVmsItemType('CameraGroup', 'MicrophoneGroup', 'SpeakerGroup', 'MetadataGroup', 'InputEventGroup', 'OutputGroup')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $ParentGroup,

        [Parameter(Mandatory, Position = 1, ParameterSetName = 'ByName')]
        [string[]]
        $Name,

        [Parameter(Mandatory, Position = 2, ParameterSetName = 'ByPath')]
        [string[]]
        $Path,

        [Parameter(Position = 3, ParameterSetName = 'ByName')]
        [Parameter(Position = 3, ParameterSetName = 'ByPath')]
        [string]
        $Description,

        [Parameter(Position = 4, ParameterSetName = 'ByName')]
        [Parameter(Position = 4, ParameterSetName = 'ByPath')]
        [Alias('DeviceCategory')]
        [ValidateSet('Camera', 'Microphone', 'Speaker', 'Input', 'Output', 'Metadata')]
        [string]
        $Type = 'Camera'
    )

    begin {
        Assert-VmsRequirementsMet
        $adjustedType = $Type
        if ($adjustedType -eq 'Input') {
            # Inputs on cameras have an object type called "InputEvent"
            # but we don't want the user to have to remember that.
            $adjustedType = 'InputEvent'
        }
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ByName' {
                $getGroupParams = @{
                    Type = $Type
                }
                $rootGroup = Get-VmsManagementServer
                if ($ParentGroup) {
                    $getGroupParams.ParentGroup = $ParentGroup
                    $rootGroup = $ParentGroup
                }
                foreach ($n in $Name) {
                    try {
                        $getGroupParams.Name = $n
                        $group = Get-VmsDeviceGroup @getGroupParams -ErrorAction SilentlyContinue
                        if ($null -eq $group) {
                            $serverTask = $rootGroup."$($adjustedType)GroupFolder".AddDeviceGroup($n, $Description)
                            $rootGroup."$($adjustedType)GroupFolder".ClearChildrenCache()
                            New-Object -TypeName "VideoOS.Platform.ConfigurationItems.$($adjustedType)Group" -ArgumentList $rootGroup.ServerId, $serverTask.Path
                        } else {
                            $group
                        }
                    } catch {
                        Write-Error -ErrorRecord $_
                    }
                }
            }
            'ByPath' {
                $params = @{
                    Type = $Type
                }
                foreach ($p in $Path) {
                    try {
                        $skip = 0
                        $pathPrefixPattern = '^/(?<type>(Camera|Microphone|Speaker|Metadata|Input|Output))(Event)?GroupFolder'
                        if ($p -match $pathPrefixPattern) {
                            $pathPrefix = $p -replace '^/(Camera|Microphone|Speaker|Metadata|Input|Output)(Event)?GroupFolder.*', '$1'
                            if ($pathPrefix -ne $params.Type) {
                                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Type')) {
                                    throw "The device group prefix '$pathPrefix' does not match the specified device group type '$Type'. Either remove the prefix from the path, or do not specify a value for the Type parameter."
                                } else {
                                    Write-Verbose "Device type '$pathPrefix' determined from the provided path."
                                    $params.Type = $pathPrefix
                                }
                            }
                            $skip = 1
                        }
                        $p | Split-VmsDeviceGroupPath | Select-Object -Skip $skip | ForEach-Object {
                            $params.Remove('Name')
                            $group = Get-VmsDeviceGroup @params -Name ($_ -replace '([\*\?\[\]])', '`$1') -ErrorAction SilentlyContinue
                            $params.Name = $_
                            if ($null -eq $group) {
                                $group = New-VmsDeviceGroup @params -ErrorAction Stop
                            }
                            $params.ParentGroup = $group
                        }
                        if (-not [string]::IsNullOrWhiteSpace($Description)) {
                            $group.Description = $Description
                            $group.Save()
                        }
                        $group
                    } catch {
                        Write-Error -ErrorRecord $_
                    }
                }
            }
            Default {
                throw "Parameter set '$_' not implemented."
            }
        }
    }
}
