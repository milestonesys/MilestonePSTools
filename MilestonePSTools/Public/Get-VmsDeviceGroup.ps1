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

function Get-VmsDeviceGroup {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    [Alias('Get-DeviceGroup')]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipeline, ParameterSetName = 'ByName')]
        [ValidateVmsItemType('CameraGroup', 'MicrophoneGroup', 'SpeakerGroup', 'MetadataGroup', 'InputEventGroup', 'OutputGroup')]
        [VideoOS.Platform.ConfigurationItems.IConfigurationItem]
        $ParentGroup,

        [Parameter(Position = 0, ParameterSetName = 'ByName')]
        [string]
        $Name = '*',

        [Parameter(Mandatory, Position = 1, ParameterSetName = 'ByPath')]
        [string[]]
        $Path,

        [Parameter(Position = 2, ParameterSetName = 'ByName')]
        [Parameter(Position = 2, ParameterSetName = 'ByPath')]
        [Alias('DeviceCategory')]
        [ValidateSet('Camera', 'Microphone', 'Speaker', 'Input', 'Output', 'Metadata')]
        [string]
        $Type = 'Camera',

        [Parameter(ParameterSetName = 'ByName')]
        [Parameter(ParameterSetName = 'ByPath')]
        [switch]
        $Recurse
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
        $rootGroup = Get-VmsManagementServer
        if ($ParentGroup) {
            $rootGroup = $ParentGroup
        }

        $matchFound = $false
        switch ($PSCmdlet.ParameterSetName) {
            'ByName' {
                $subGroups = $rootGroup."$($adjustedType)GroupFolder"."$($adjustedType)Groups"
                $subGroups | Where-Object Name -like $Name | Foreach-Object {
                    if ($null -eq $_) { return }
                    $matchFound = $true
                    $_
                    if ($Recurse) {
                        $_ | Get-VmsDeviceGroup -Type $Type -Recurse
                    }
                }
            }

            'ByPath' {
                foreach ($groupPath in $Path) {
                    $pathPrefixPattern = '^/(?<type>(Camera|Microphone|Speaker|Metadata|Input|Output))(Event)?GroupFolder'
                    if ($groupPath -match $pathPrefixPattern) {
                        $pathPrefix = $groupPath -replace '^/(Camera|Microphone|Speaker|Metadata|Input|Output)(Event)?GroupFolder.*', '$1'
                        if ($pathPrefix -ne $Type) {
                            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Type')) {
                                throw "The device group prefix '$pathPrefix' does not match the specified device group type '$Type'. Either remove the prefix from the path, or do not specify a value for the Type parameter."
                            } else {
                                Write-Verbose "Device type '$pathPrefix' determined from the provided path."
                                $Type = $pathPrefix
                            }
                        }
                    }
                    $params = @{
                        Type        = $Type
                        ErrorAction = 'SilentlyContinue'
                    }
                    $pathInterrupted = $false
                    $groupPath = $groupPath -replace '^/(Camera|Microphone|Speaker|Metadata|InputEvent|Output)GroupFolder', ''
                    $pathParts = $groupPath | Split-VmsDeviceGroupPath
                    foreach ($name in $pathParts) {
                        $params.Name = $name
                        $group = Get-VmsDeviceGroup @params
                        if ($null -eq $group) {
                            $pathInterrupted = $true
                            break
                        }
                        $params.ParentGroup = $group
                    }
                    if ($pathParts -and -not $pathInterrupted) {
                        $matchFound = $true
                        $params.ParentGroup
                        if ($Recurse) {
                            $params.ParentGroup | Get-VmsDeviceGroup -Type $Type -Recurse
                        }
                    }
                    if ($null -eq $pathParts -and $Recurse) {
                        Get-VmsDeviceGroup -Type $Type -Recurse
                    }
                }
            }
        }

        if (-not $matchFound -and -not [management.automation.wildcardpattern]::ContainsWildcardCharacters($Name)) {
            Write-Error "No $Type group found with the name '$Name'"
        }
    }
}
