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

function Copy-VmsClientProfile {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.2')]
    [RequiresVmsFeature('SmartClientProfiles')]
    [OutputType([VideoOS.Platform.ConfigurationItems.ClientProfile])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter([MilestonePSTools.Utility.MipItemNameCompleter[VideoOS.Platform.ConfigurationItems.ClientProfile]])]
        [ClientProfileTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.ClientProfile]
        $ClientProfile,

        [Parameter(Mandatory, Position = 0)]
        [string]
        $NewName
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $newProfile = New-VmsClientProfile -Name $NewName -Description $ClientProfile.Description -ErrorAction Stop
        if ($ClientProfile.IsDefaultProfile) {
            # New client profiles are by default an exact copy of the default profile. No need to copy attributes to the new profile.
            $newProfile
            return
        }

        foreach ($attributes in $ClientProfile | Get-VmsClientProfileAttributes) {
            $newProfile | Set-VmsClientProfileAttributes -Attributes $attributes -Verbose:($VerbosePreference -eq 'Continue')
        }
    }
}

