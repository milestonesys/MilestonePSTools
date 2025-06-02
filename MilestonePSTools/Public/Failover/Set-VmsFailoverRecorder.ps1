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

function Set-VmsFailoverRecorder {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.FailoverRecorder])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('RecordingServerFailover')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter([MipItemNameCompleter[FailoverRecorder]])]
        [MipItemTransformation([FailoverRecorder])]
        [FailoverRecorder]
        $FailoverRecorder,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [bool]
        $Enabled,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string]
        $DatabasePath,

        [Parameter()]
        [ValidateRange(0, 65535)]
        [int]
        $UdpPort,

        [Parameter()]
        [string]
        $MulticastServerAddress,

        [Parameter()]
        [bool]
        $PublicAccessEnabled,

        [Parameter()]
        [string]
        $PublicWebserverHostName,

        [Parameter()]
        [ValidateRange(0, 65535)]
        [int]
        $PublicWebserverPort,

        [Parameter()]
        [switch]
        $Unassigned,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($Unassigned) {
            if ($FailoverRecorder.ParentItemPath -eq '/') {
                Get-VmsRecordingServer | Where-Object {
                    $_.RecordingServerFailoverFolder.RecordingServerFailovers[0].HotStandby -eq $FailoverRecorder.Path
                } | Set-VmsRecordingServer -DisableFailover -Verbose:($VerbosePreference -eq 'Continue')
            } else {
                $group = Get-VmsFailoverGroup -Id ($FailoverRecorder.ParentItemPath -replace '\w+\[(.+)\]', '$1')
                $group | Remove-VmsFailoverRecorder -FailoverRecorder $FailoverRecorder
            }
        }

        $dirty = $false
        $settableProperties = ($FailoverRecorder | Get-Member -MemberType Property | Where-Object Definition -match 'set;').Name
        foreach ($property in $MyInvocation.BoundParameters.GetEnumerator() | Where-Object Key -in $settableProperties) {
            $key = $property.Key
            $newValue = $property.Value
            if ($FailoverRecorder.$key -cne $newValue -and $PSCmdlet.ShouldProcess("FailoverRecorder $($FailoverRecorder.Name)", "Change $key to $newValue")) {
                $FailoverRecorder.$key = $newValue
                $dirty = $true
            }
        }
        if ($dirty) {
            try {
                if ($FailoverRecorder.MulticastServerAddress -eq [string]::Empty) {
                    Write-Verbose 'Changing MulticastServerAddress to 0.0.0.0 because an empty string will not pass validation as of XProtect 2023 R1. Bug #581349.'
                    $FailoverRecorder.MulticastServerAddress = '0.0.0.0'
                }
                $FailoverRecorder.Save()
            } catch [VideoOS.Platform.Proxy.ConfigApi.ValidateResultException] {
                $FailoverRecorder = Get-VmsFailoverRecorder -Id $FailoverRecorder.Id
                $_ | HandleValidateResultException -TargetObject $FailoverRecorder -ItemName $FailoverRecorder.Name
            }
        }
        if ($PassThru) {
            $FailoverRecorder
        }
    }
}
