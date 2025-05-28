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

function New-VmsClientProfile {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.ConfigurationItems.ClientProfile])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('SmartClientProfiles')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position = 0)]
        [string]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName, Position = 1)]
        [string]
        $Description
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            $serverTask = (Get-VmsManagementServer -ErrorAction Stop).ClientProfileFolder.AddClientProfile($Name, $Description)
            if ($serverTask.State -ne 'Success') {
                Write-Error -Message "Error creating new client profile: $($serverTask.ErrorText)" -TargetObject $serverTask
                return
            }
            Get-VmsClientProfile -Id ($serverTask.Path -replace 'ClientProfile\[(.+)\]', '$1')
        } catch {
            Write-Error -Message $_.Message -Exception $_.Exception
        }
    }
}

