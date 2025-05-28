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

function Invoke-VmsLicenseActivation {
    [CmdletBinding()]
    [Alias('Invoke-LicenseActivation')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.2')]
    [OutputType([VideoOS.Platform.ConfigurationItems.LicenseDetailChildItem])]
    param (
        [Parameter(Mandatory)]
        [pscredential]
        $Credential,

        [Parameter()]
        [switch]
        $EnableAutoActivation,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
        Show-DeprecationWarning $MyInvocation
    }

    process {
        try {
            $licenseInfo = Get-VmsLicenseInfo
            $result = $licenseInfo.ActivateLicense($Credential.UserName, $Credential.Password, $EnableAutoActivation) | Wait-VmsTask -Title 'Performing online license activation' -Cleanup
            $state = ($result.Properties | Where-Object Key -eq 'State').Value
            if ($state -eq 'Success') {
                if ($PassThru) {
                    Get-VmsLicenseDetails
                }
            } else {
                $errorText = ($result.Properties | Where-Object Key -eq 'ErrorText').Value
                if ([string]::IsNullOrWhiteSpace($errorText)) {
                    $errorText = "Unknown error."
                }
                Write-Error "Call to ActivateLicense failed. $($errorText.Trim('.'))."
            }
        } catch {
            Write-Error -Message $_.Message -Exception $_.Exception
        }
    }
}

