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

function Set-VmsLicense {
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
                throw [System.IO.FileNotFoundException]::new('Set-VmsLicense could not find the file.', $filePath)
            }
            $bytes = [IO.File]::ReadAllBytes($filePath)
            $b64 = [Convert]::ToBase64String($bytes)
            $result = $ms.LicenseInformationFolder.LicenseInformations[0].ChangeLicense($b64)
            if ($result.State -eq 'Success') {
                $oldSlc = $ms.LicenseInformationFolder.LicenseInformations[0].Slc
                $ms.ClearChildrenCache()
                $newSlc = $ms.LicenseInformationFolder.LicenseInformations[0].Slc
                if ($oldSlc -eq $newSlc) {
                    Write-Verbose "The software license code in the license file passed to Set-VmsLicense is the same as the existing software license code."
                }
                else {
                    Write-Verbose "Set-VmsLicense changed the software license code from $oldSlc to $newSlc."
                }
                Write-Output $ms.LicenseInformationFolder.LicenseInformations[0]
            }
            else {
                Write-Error "Call to ChangeLicense failed. $($result.ErrorText.Trim('.'))."
            }
        }
        catch {
            Write-Error -Message $_.Message -Exception $_.Exception
        }
    }
}

