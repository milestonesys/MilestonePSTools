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

function Get-VmsLicenseInfo {
    [CmdletBinding()]
    [Alias('Get-LicenseInfo')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('20.2')]
    [OutputType([VideoOS.Platform.ConfigurationItems.LicenseInformation])]
    param ()

    begin {
        Assert-VmsRequirementsMet
        Show-DeprecationWarning $MyInvocation
    }

    process {
        $site = Get-VmsSite
        [VideoOS.Platform.ConfigurationItems.LicenseInformation]::new($site.FQID.ServerId, "LicenseInformation[$($site.FQID.ObjectId)]")
    }
}

