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
    }

    process {
        $form = [MilestonePSTools.UI.CustomItemPickerForm]::new();
        $form.KindFilter = $Kind
        $form.CategoryFilter = $Category
        $form.AllowFolders = $AllowFolders
        $form.AllowServers = $AllowServers
        $form.KindUserSelectable = $KindUserSelectable
        $form.CategoryUserSelectable = $CategoryUserSelectable
        $form.SingleSelect = $SingleSelect
        $form.GroupTabVisable = -not $HideGroupsTab
        $form.ServerTabVisable = -not $HideServerTab
        $form.Icon = [System.Drawing.Icon]::FromHandle([VideoOS.Platform.UI.Util]::ImageList.Images[[VideoOS.Platform.UI.Util]::SDK_GeneralIx].GetHicon())
        $form.Text = $Title
        $form.TopMost = $true
        $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
        $form.BringToFront()
        $form.Activate()

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

