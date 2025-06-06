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

function Set-VmsRestrictedMedia {
    [CmdletBinding()]
    [Alias('Set-VmsRm')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('23.2')]
    [RequiresVmsFeature('RestrictedMedia')]
    [OutputType([VideoOS.Common.Proxy.Server.WCF.RestrictedMedia])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='Media can also be singular.')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Common.Proxy.Server.WCF.RestrictedMedia]
        $InputObject,

        [Parameter()]
        [guid[]]
        $IncludeDeviceId = [guid[]]::new(0),

        [Parameter()]
        [guid[]]
        $ExcludeDeviceId = [guid[]]::new(0),

        [Parameter()]
        [string]
        $Header,
        
        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [datetime]
        $StartTime,

        [Parameter()]
        [datetime]
        $EndTime,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        if (!$PSBoundParameters.ContainsKey('Header')) {
            $Header = $InputObject.Header
        }
        if (!$PSBoundParameters.ContainsKey('Description')) {
            $Description = $InputObject.Description
        }
        if (!$PSBoundParameters.ContainsKey('StartTime')) {
            $StartTime = $InputObject.StartTime
        }
        if (!$PSBoundParameters.ContainsKey('EndTime')) {
            $EndTime = $InputObject.EndTime
        }
        $result = { (Get-IServerCommandService).RestrictedMediaUpdate(
            $InputObject.Id,
            $IncludeDeviceId,
            $ExcludeDeviceId,
            $Header,
            $Description,
            $StartTime,
            $EndTime
        ) } | ExecuteWithRetry -ClearVmsCache
        foreach ($fault in $result.FaultDevices) {
            Write-Error -Message "$($fault.Message) DeviceId = '$($fault.DeviceId)'." -ErrorId 'RestrictedMedia.Fault' -Category InvalidResult
        }
        foreach ($warning in $result.WarningDevices) {
            Write-Warning -Message "$($warning.Message) DeviceId = '$($warning.DeviceId)'."
        }
        if ($PassThru -and $result.RestrictedMedia) {
            $result.RestrictedMedia
        }
    }
}

