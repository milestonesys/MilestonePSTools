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

function Set-VmsCameraMotion {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.Camera])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [VideoOS.Platform.ConfigurationItems.Camera[]]
        $Camera,

        [Parameter()]
        [ValidateSet('Normal', 'Optimized', 'Fast')]
        [string]
        $DetectionMethod,

        [Parameter()]
        [bool]
        $Enabled,

        [Parameter()]
        [string]
        $ExcludeRegions,

        [Parameter()]
        [bool]
        $GenerateMotionMetadata,

        [Parameter()]
        [ValidateSet('Grid8X8', 'Grid16X16', 'Grid32X32', 'Grid64X64')]
        [string]
        $GridSize,

        [Parameter()]
        [ValidateSet('Automatic', 'Off')]
        [RequiresVmsFeature('HardwareAcceleratedVMD')]
        [string]
        $HardwareAccelerationMode,

        [Parameter()]
        [bool]
        $KeyframesOnly,

        [Parameter()]
        [ValidateRange(0, 300)]
        [int]
        $ManualSensitivity,

        [Parameter()]
        [bool]
        $ManualSensitivityEnabled,

        [Parameter()]
        [ValidateSet('Ms100', 'Ms250', 'Ms500', 'Ms750', 'Ms1000')]
        [string]
        $ProcessTime,

        [Parameter()]
        [ValidateRange(0, 10000)]
        [int]
        $Threshold,

        [Parameter()]
        [bool]
        $UseExcludeRegions,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet -ErrorAction Stop
        $members = @{}
    }
    
    process {
        foreach ($currentDevice in $Camera) {
            $dirty = $false
            try {
                $motion = $currentDevice.MotionDetectionFolder.MotionDetections[0]
                if ($members.Count -eq 0) {
                    # Cache settable property names as keys in hashtable
                    $motion | Get-Member -MemberType Property | Where-Object Definition -match 'set;' | ForEach-Object {
                        $members[$_.Name] = $null
                    }
                }
                foreach ($parameter in $PSCmdlet.MyInvocation.BoundParameters.GetEnumerator()) {
                    $key, $newValue = $parameter.Key, $parameter.Value
                    if (!$members.ContainsKey($key)) {
                        continue
                    } elseif ($motion.$key -eq $newValue) {
                        Write-Verbose "Motion detection setting '$key' is already '$newValue' on $currentDevice"
                        continue
                    }
                    Write-Verbose "Changing motion detection setting '$key' to '$newValue' on $currentDevice"
                    $motion.$key = $newValue
                    $dirty = $true
                }
                if ($PSCmdlet.ShouldProcess($currentDevice, "Update motion detection settings")) {
                    if ($dirty) {
                        $motion.Save()
                    }
                    if ($PassThru) {
                        $currentDevice
                    }
                }
            } catch {
                Write-Error -TargetObject $currentDevice -Exception $_.Exception -Message $_.Exception.Message -Category $_.CategoryInfo.Category
            }
        }
    }
}

