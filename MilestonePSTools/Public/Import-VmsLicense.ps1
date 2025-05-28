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

function Import-VmsLicense {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.2')]
    [OutputType([VideoOS.Platform.ConfigurationItems.LicenseInformation])]
    param (
        [Parameter(Mandatory)]
        [string]
        $Path
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            $filePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
            if (-not (Test-Path $filePath)) {
                throw [System.IO.FileNotFoundException]::new('Import-VmsLicense could not find the file.', $filePath)
            }
            $bytes = [IO.File]::ReadAllBytes($filePath)
            $b64 = [Convert]::ToBase64String($bytes)
            $ms = Get-VmsManagementServer
            $result = $ms.LicenseInformationFolder.LicenseInformations[0].UpdateLicense($b64)
            if ($result.State -eq 'Success') {
                $ms.LicenseInformationFolder.ClearChildrenCache()
                Write-Output $ms.LicenseInformationFolder.LicenseInformations[0]
            }
            else {
                Write-Error "Failed to import updated license file. $($result.ErrorText.Trim('.'))."
            }
        }
        catch {
            Write-Error -Message $_.Message -Exception $_.Exception
        }
    }
}

