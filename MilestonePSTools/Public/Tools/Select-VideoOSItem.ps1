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

function Select-VideoOSItem {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresInteractiveSession()]
    param (
        [Parameter()]
        [string]
        $Title = "Select Item(s)",
        [Parameter()]
        [guid[]]
        $Kind,
        [Parameter()]
        [VideoOS.Platform.Admin.Category[]]
        $Category,
        [Parameter()]
        [switch]
        $SingleSelect,
        [Parameter()]
        [switch]
        $AllowFolders,
        [Parameter()]
        [switch]
        $AllowServers,
        [Parameter()]
        [switch]
        $KindUserSelectable,
        [Parameter()]
        [switch]
        $CategoryUserSelectable,
        [Parameter()]
        [switch]
        $FlattenOutput,
        [Parameter()]
        [switch]
        $HideGroupsTab,
        [Parameter()]
        [switch]
        $HideServerTab
    )

    begin {
        Assert-VmsRequirementsMet
        if ($Category) {
            Write-Warning "The Category parameter is no longer supported after migrating to the MIP SDK ItemPickerWpfWindow, and will be ignored."
        }
        if ($KindUserSelectable) {
            Write-Warning "The KindUserSelectable parameter is no longer supported after migrating to the MIP SDK ItemPickerWpfWindow, and will be ignored."
        }
        if ($CategoryUserSelectable) {
            Write-Warning "The CategoryUserSelectable parameter is no longer supported after migrating to the MIP SDK ItemPickerWpfWindow, and will be ignored."
        }
        if ($HideGroupsTab -or $HideServerTab) {
            Write-Warning "The HideGroupsTab and HideServerTab parameters are no longer supported after migrating to the MIP SDK ItemPickerWpfWindow, which presents a single item tree instead of separate Group/Server tabs."
        }
    }

    process {
        $form = [MilestonePSTools.UI.CustomItemPickerForm]::new();
        $form.KindFilter = $Kind
        $form.AllowFolders = $AllowFolders
        $form.AllowServers = $AllowServers
        $form.SingleSelect = $SingleSelect
        $form.Icon = [System.Drawing.Icon]::FromHandle([VideoOS.Platform.UI.Util]::ImageList.Images[[VideoOS.Platform.UI.Util]::SDK_GeneralIx].GetHicon())
        $form.Text = $Title
        $form.TopMost = $true
        $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

        if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            if ($FlattenOutput) {
                Write-Output $form.ItemsSelectedFlattened
            }
            else {
                Write-Output $form.ItemsSelected
            }
        }
    }
}

