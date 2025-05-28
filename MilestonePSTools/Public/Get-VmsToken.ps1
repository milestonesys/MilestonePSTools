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

function Get-VmsToken {
    [CmdletBinding(DefaultParameterSetName = 'CurrentSite')]
    [OutputType([string])]
    [Alias('Get-Token')]
    [RequiresVmsConnection()]
    param (
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ServerId')]
        [VideoOS.Platform.ServerId]
        $ServerId,

        [Parameter(ValueFromPipeline, ParameterSetName = 'Site')]
        [VideoOS.Platform.Item]
        $Site
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            switch ($PSCmdlet.ParameterSetName) {
                'CurrentSite' {
                    [VideoOS.Platform.Login.LoginSettingsCache]::GetLoginSettings((Get-VmsSite).FQID).Token
                }

                'ServerId' {
                    [VideoOS.Platform.Login.LoginSettingsCache]::GetLoginSettings($ServerId).Token
                }

                'Site' {
                    [VideoOS.Platform.Login.LoginSettingsCache]::GetLoginSettings($Site.FQID).Token
                }

                Default {
                    throw "ParameterSet '$_' not implemented."
                }
            }
        } catch {
            Write-Error -ErrorRecord $_
        }
    }
}

