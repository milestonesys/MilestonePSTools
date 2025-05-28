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

function ExportVmsLoginSettings {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()
    
    process {
        $settings = Get-LoginSettings | Where-Object Guid -EQ ([milestonepstools.connection.milestoneconnection]::Instance.MainSite).FQID.ObjectId
        $vmsProfile = @{
            ServerAddress     = $settings.Uri
            Credential        = $settings.NetworkCredential | ConvertTo-PSCredential -ErrorAction SilentlyContinue
            BasicUser         = $settings.IsBasicUser
            SecureOnly        = $settings.SecureOnly
            IncludeChildSites = [milestonepstools.connection.milestoneconnection]::Instance.IncludeChildSites
            AcceptEula        = $true
        }
        if ($null -eq $vmsProfile.Credential) {
            $vmsProfile.Remove('Credential')
        }
        $vmsProfile
    }
}
