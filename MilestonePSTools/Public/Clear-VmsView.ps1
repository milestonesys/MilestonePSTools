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

function Clear-VmsView {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.View])]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 1)]
        [VideoOS.Platform.ConfigurationItems.View[]]
        $View,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        foreach ($v in $View) {
            if ($PSCmdlet.ShouldProcess($v.DisplayName, "Reset to empty ViewItem layout")) {
                foreach ($viewItem in $v.ViewItemChildItems) {
                    $id = New-Guid
                    $viewItem.ViewItemDefinitionXml = '<viewitem id="{0}" displayname="Empty ViewItem" shortcut="" type="VideoOS.RemoteClient.Application.Data.Configuration.EmptyViewItem, VideoOS.RemoteClient.Application"><properties /></viewitem>' -f $id.ToString()
                }
                $v.Save()
            }
            if ($PassThru) {
                Write-Output $View
            }
        }
    }
}

