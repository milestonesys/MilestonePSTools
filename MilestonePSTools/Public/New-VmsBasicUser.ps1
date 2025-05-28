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

function New-VmsBasicUser {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.ConfigurationItems.BasicUser])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [SecureStringTransformAttribute()]
        [securestring]
        $Password,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Description,

        [Parameter(ValueFromPipelineByPropertyName)]
        [BoolTransformAttribute()]
        [bool]
        $CanChangePassword = $true,

        [Parameter(ValueFromPipelineByPropertyName)]
        [BoolTransformAttribute()]
        [bool]
        $ForcePasswordChange,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Enabled', 'LockedOutByAdmin')]
        [string]
        $Status = 'Enabled'
    )

    begin {
        Assert-VmsRequirementsMet
        $ms = Get-VmsManagementServer
    }

    process {
        try {
            $result = $ms.BasicUserFolder.AddBasicUser($Name, $Description, $CanChangePassword, $ForcePasswordChange, $Password, $Status)
            [VideoOS.Platform.ConfigurationItems.BasicUser]::new($ms.ServerId, $result.Path)
        } catch {
            Write-Error -ErrorRecord $_
        }
    }
}

