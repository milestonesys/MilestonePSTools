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

function New-VmsLoginProvider {
    [CmdletBinding()]
    [OutputType([VideoOS.Platform.ConfigurationItems.LoginProvider])]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('22.1')]
    param (
        [Parameter(Mandatory)]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [string]
        $ClientId,

        [Parameter(Mandatory)]
        [SecureStringTransformAttribute()]
        [securestring]
        $ClientSecret,

        [Parameter()]
        [string]
        $CallbackPath = '/signin-oidc',

        [Parameter(Mandatory)]
        [uri]
        $Authority,

        [Parameter()]
        [string]
        $UserNameClaim,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Scopes = @(),

        [Parameter()]
        [bool]
        $PromptForLogin = $true,

        [Parameter()]
        [bool]
        $Enabled = $true
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            $credential = [pscredential]::new($ClientId, $ClientSecret)
            $folder = (Get-VmsManagementServer).LoginProviderFolder
            $serverTask = $folder.AddLoginProvider([guid]::Empty, $Name, $ClientId, $credential.GetNetworkCredential().Password, $CallbackPath, $Authority, $UserNameClaim, $Scopes, $PromptForLogin, $Enabled)
            $loginProvider = Get-VmsLoginProvider | Where-Object Path -eq $serverTask.Path
            if ($null -ne $loginProvider) {
                $loginProvider
            }
        } catch {
            Write-Error -Message $_.Exception.Message -Exception $_.Exception -TargetObject $serverTask
        }
    }
}

