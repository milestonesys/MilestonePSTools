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

function Export-VmsLicenseRequest {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.2')]
    [OutputType([System.IO.FileInfo])]
    param (
        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $Force,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            $filePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
            if ((Test-Path $filePath) -and -not $Force) {
                Write-Error "File '$Path' already exists. To overwrite an existing file, specify the -Force switch."
                return
            }
            $ms = Get-VmsManagementServer
            $result = $ms.LicenseInformationFolder.LicenseInformations[0].RequestLicense()
            if ($result.State -ne 'Success') {
                Write-Error "Failed to create license request. $($result.ErrorText.Trim('.'))."
                return
            }

            $content = [Convert]::FromBase64String($result.GetProperty('License'))
            [io.file]::WriteAllBytes($filePath, $content)

            if ($PassThru) {
                Get-Item -Path $filePath
            }
        }
        catch {
            Write-Error $_
        }
    }
}

