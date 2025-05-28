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

function Get-StreamProperties {
    [CmdletBinding()]
    [OutputType([VideoOS.ConfigurationApi.ClientService.Property[]])]
    [RequiresVmsConnection()]
    param (
        # Specifies the camera to retrieve stream properties for
        [Parameter(ValueFromPipeline, Mandatory, ParameterSetName = 'ByName')]
        [Parameter(ValueFromPipeline, Mandatory, ParameterSetName = 'ByNumber')]
        [VideoOS.Platform.ConfigurationItems.Camera]
        $Camera,

        # Specifies a StreamUsageChildItem from Get-Stream
        [Parameter(ParameterSetName = 'ByName')]
        [ValidateNotNullOrEmpty()]
        [string]
        $StreamName,

        # Specifies the stream number starting from 0. For example, "Video stream 1" is usually in the 0'th position in the StreamChildItems collection.
        [Parameter(ParameterSetName = 'ByNumber')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]
        $StreamNumber
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ByName' {
                $stream = (Get-ConfigurationItem -Path "DeviceDriverSettings[$($Camera.Id)]").Children | Where-Object { $_.ItemType -eq 'Stream' -and $_.DisplayName -like $StreamName }
                if ($null -eq $stream -and ![system.management.automation.wildcardpattern]::ContainsWildcardCharacters($StreamName)) {
                    Write-Error "No streams found on $($Camera.Name) matching the name '$StreamName'"
                    return
                }
                foreach ($obj in $stream) {
                    Write-Output $obj.Properties
                }
            }
            'ByNumber' {
                $streams = (Get-ConfigurationItem -Path "DeviceDriverSettings[$($Camera.Id)]").Children | Where-Object { $_.ItemType -eq 'Stream' }
                if ($StreamNumber -lt $streams.Count) {
                    Write-Output ($streams[$StreamNumber].Properties)
                }
                else {
                    Write-Error "There are $($streams.Count) streams available on the camera and stream number $StreamNumber does not exist. Remember to index the streams from zero."
                }
            }
            Default {}
        }
    }
}

