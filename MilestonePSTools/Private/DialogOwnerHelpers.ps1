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

function Invoke-WithDialogOwner {
    [CmdletBinding()]
    param(
        [IntPtr] $Handle = [IntPtr]::Zero,
        [switch] $TopMostFallback,
        [Parameter(Mandatory)][ScriptBlock] $ScriptBlock
    )

    Add-Type -AssemblyName System.Windows.Forms | Out-Null

    $owner = $null
    $topMostOwnerForm = $null
    $dialogOwner = $null
    try {
        if ($Handle -eq [IntPtr]::Zero -and $global:UiOwnerHandle) {
            $Handle = [IntPtr]$global:UiOwnerHandle
        }

        if ($Handle -ne [IntPtr]::Zero) {
            $owner = New-Object System.Windows.Forms.NativeWindow
            $owner.AssignHandle($Handle)
        } elseif ($TopMostFallback) {
            $topMostOwnerForm = New-Object System.Windows.Forms.Form
            $topMostOwnerForm.TopMost = $true
            $topMostOwnerForm.ShowInTaskbar = $false
            $topMostOwnerForm.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
            $topMostOwnerForm.Size = [System.Drawing.Size]::new(1, 1)
        }

        if ($owner) {
            $dialogOwner = $owner
        } elseif ($topMostOwnerForm) {
            $dialogOwner = $topMostOwnerForm
        }

        return & $ScriptBlock $dialogOwner
    }
    finally {
        if ($owner) {
            $owner.ReleaseHandle()
        }
        if ($topMostOwnerForm) {
            $topMostOwnerForm.Dispose()
        }
    }
}

function Invoke-WithWpfDialogOwner {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][System.Windows.Window] $Window,
        [IntPtr] $Handle = [IntPtr]::Zero,
        [switch] $TopMostFallback,
        [Parameter(Mandatory)][ScriptBlock] $ScriptBlock
    )

    Add-Type -AssemblyName PresentationFramework | Out-Null

    $dialogOwnerHandle = $Handle
    if ($dialogOwnerHandle -eq [IntPtr]::Zero -and $global:UiOwnerHandle) {
        $dialogOwnerHandle = [IntPtr]$global:UiOwnerHandle
    }

    if ($dialogOwnerHandle -ne [IntPtr]::Zero) {
        $interop = [System.Windows.Interop.WindowInteropHelper]::new($Window)
        $interop.Owner = $dialogOwnerHandle
    } elseif ($TopMostFallback) {
        $Window.Topmost = $true
    }

    return & $ScriptBlock $Window
}
