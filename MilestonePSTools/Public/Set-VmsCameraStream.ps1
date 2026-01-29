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
    [OutputType([MilestonePSTools.VmsCameraStreamConfig])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'AddOrUpdateStream')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'RemoveStream')]
        [MilestonePSTools.VmsCameraStreamConfig[]]
        $Stream,

        [Parameter(Mandatory, ParameterSetName = 'RemoveStream')]
        [switch]
        $Disabled,

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
        [MilestonePSTools.ValidateVmsVersion('23.2')]
        [MilestonePSTools.ValidateVmsFeature('MultistreamRecording')]
        [switch]
        $PlaybackDefault,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [switch]
        $UseEdge,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [hashtable]
        $Settings = @{},

        [Parameter()]
        [switch]
        $PassThru,

        [Parameter(ValueFromRemainingArguments, DontShow)]
        [object[]]
        $ExtraParams
    )

    begin {
        Assert-VmsRequirementsMet
        $modifiedStreams = @{}
    }

    process {
        foreach ($currentStream in $Stream) {
            # Use only for $PSCmdlet.ShouldProcess
            $targetName = "$($currentStream.Name) on $($currentStream.Camera.Name)"

            # Disable stream
            if ($Disabled) {
                if ($PSCmdlet.ShouldProcess($targetName, 'Remove')) {
                    $currentStream.Enabled = $false
                }
                continue
            }

            # Add stream if needed
            $parametersRequiringStreamUsage = @('DisplayName', 'LiveDefault', 'LiveMode', 'PlaybackDefault', 'Recorded', 'RecordingTrack', 'UseEdge')
            $streamUsageRequired = $null -ne ($PSCmdlet.MyInvocation.BoundParameters.Keys | Where-Object { $_ -in $parametersRequiringStreamUsage })
            if (!$currentStream.Enabled -and $streamUsageRequired) {
                if ($PSCmdlet.ShouldProcess($targetName, 'Adding a new stream usage')) {
                    $currentStream.Enabled = $true
                }
            }

            foreach ($usagePropertyName in $parametersRequiringStreamUsage) {
                $paramValue = $PSCmdlet.MyInvocation.BoundParameters[$usagePropertyName]
                if (!$PSCmdlet.MyInvocation.BoundParameters.ContainsKey($usagePropertyName)) {
                    continue
                }
                if ($paramValue -ceq $currentStream.$usagePropertyName) {
                    continue
                }
                if ($PSCmdlet.ShouldProcess($targetName, "Set $usagePropertyName to $paramValue")) {
                    $currentStream.$usagePropertyName = $paramValue
                }
            }

            # Populate $Settings from $ExtraParams if present
            for ($i = 1; $i -lt $ExtraParams.Count; $i += 2) {
                if ($i % 2 -eq 0) {
                    continue
                }
                if ($ExtraParams[$i - 1] -match '^-?(?<key>[a-z]+)$') {
                    $Settings[$Matches['key']] = $ExtraParams[$i]
                } else {
                    Write-Warning "Ignoring ExtraParam '$($ExtraParams[$i - 1])' due to invalid format."
                    $i += 2
                }
            }
            foreach ($key in $Settings.Keys) {
                if (!$currentStream.Settings.ContainsKey($key)) {
                    Write-Warning "A setting with the key '$key' was not found on $targetName"
                    continue
                }
                if ($currentStream.Settings[$key] -ceq $Settings[$key]) {
                    continue
                }
                if ($PSCmdlet.ShouldProcess($targetName, "Change $key from $($currentStream.Settings[$key]) to $($Settings[$key])")) {
                    $null = $currentStream.SetValue($key, $Settings[$key])
                }
            }

            if ($currentStream.Dirty) {
                $modifiedStreams[$currentStream.Camera.Id] = $currentStream
            }

            if ($PassThru) {
                $currentStream
            }
        }
    }

    end {
        foreach ($currentStream in $modifiedStreams.Values) {
            $targetName = "$($currentStream.Name) on $($currentStream.Camera.Name)"
            try {
                $currentStream.Save()
            } catch [VideoOS.Platform.Proxy.ConfigApi.ValidateResultException] {
                # Call Update to refresh all properties with values from server
                $currentStream.Update()
                $errorText = $_.Exception.ValidateResult.ErrorResults.ErrorText
                $errorId = $_.Exception.ValidateResult.ErrorResults.ErrorTextId
                Write-Error -Message $errorText -ErrorId $errorId -Exception $_.Exception -TargetObject $currentStream
            }
        }
    }
}
