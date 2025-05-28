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

function Get-VmsHardwarePassword {
    [CmdletBinding()]
    [OutputType([string])]
    [Alias('Get-HardwarePassword')]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.Hardware]
        $Hardware
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            $serverTask = $Hardware.ReadPasswordHardware()
            if ($serverTask.State -ne [VideoOS.Platform.ConfigurationItems.StateEnum]::Success) {
                Write-Error -Message "ReadPasswordHardware error: $(t.ErrorText)" -TargetObject $Hardware
                return
            }
            $serverTask.GetProperty('Password')
        } catch {
            Write-Error -Message $_.Exception.Message -Exception $_.Exception -TargetObject $Hardware
        }
    }
}

