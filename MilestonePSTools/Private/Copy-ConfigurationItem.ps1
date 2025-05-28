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

function Copy-ConfigurationItem {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [pscustomobject]
        $InputObject,
        [parameter(Mandatory, Position = 1)]
        [VideoOS.ConfigurationApi.ClientService.ConfigurationItem]
        $DestinationItem
    )

    process {
        if (!$DestinationItem.ChildrenFilled) {
            Write-Verbose "$($DestinationItem.DisplayName) has not been retrieved recursively. Retrieving child items now."
            $DestinationItem = $DestinationItem | Get-ConfigurationItem -Recurse -Sort
        }

        $srcStack = New-Object -TypeName System.Collections.Stack
        $srcStack.Push($InputObject)
        $dstStack = New-Object -TypeName System.Collections.Stack
        $dstStack.Push($DestinationItem)

        Write-Verbose "Configuring $($DestinationItem.DisplayName) ($($DestinationItem.Path))"
        while ($dstStack.Count -gt 0) {
            $dirty = $false
            $src = $srcStack.Pop()
            $dst = $dstStack.Pop()

            if (($src.ItemCategory -ne $dst.ItemCategory) -or ($src.ItemType -ne $dst.ItemType)) {
                Write-Error "Source and Destination ConfigurationItems are different"
                return
            }

            if ($src.EnableProperty.Enabled -ne $dst.EnableProperty.Enabled) {
                Write-Verbose "$(if ($src.EnableProperty.Enabled) { "Enabling"} else { "Disabling" }) $($dst.DisplayName)"
                $dst.EnableProperty.Enabled = $src.EnableProperty.Enabled
                $dirty = $true
            }

            $srcChan = $src.Properties | Where-Object { $_.Key -eq "Channel"} | Select-Object -ExpandProperty Value
            $dstChan = $dst.Properties | Where-Object { $_.Key -eq "Channel"} | Select-Object -ExpandProperty Value
            if ($srcChan -ne $dstChan) {
                Write-Error "Sorting mismatch between source and destination configuration."
                return
            }

            foreach ($srcProp in $src.Properties) {
                $dstProp = $dst.Properties | Where-Object Key -eq $srcProp.Key
                if ($null -eq $dstProp) {
                    Write-Verbose "Key '$($srcProp.Key)' not found on $($dst.Path)"
                    Write-Verbose "Available keys`r`n$($dst.Properties | Select-Object Key, Value | Format-Table)"
                    continue
                }
                if (!$srcProp.IsSettable -or $srcProp.ValueType -eq 'PathList' -or $srcProp.ValueType -eq 'Path') { continue }
                if ($srcProp.Value -ne $dstProp.Value) {
                    Write-Verbose "Changing $($dstProp.DisplayName) to $($srcProp.Value) on $($dst.Path)"
                    $dstProp.Value = $srcProp.Value
                    $dirty = $true
                }
            }
            if ($dirty) {
                if ($dst.ItemCategory -eq "ChildItem") {
                    $result = $lastParent | Set-ConfigurationItem
                } else {
                    $result = $dst | Set-ConfigurationItem
                }

                if (!$result.ValidatedOk) {
                    foreach ($errorResult in $result.ErrorResults) {
                        Write-Error $errorResult.ErrorText
                    }
                }
            }

            if ($src.Children.Count -eq $dst.Children.Count -and $src.Children.Count -gt 0) {
                foreach ($child in $src.Children) {
                    $srcStack.Push($child)
                }
                foreach ($child in $dst.Children) {
                    $dstStack.Push($child)
                }
                if ($dst.ItemCategory -eq "Item") {
                    $lastParent = $dst
                }
            } elseif ($src.Children.Count -ne 0) {
                Write-Warning "Number of child items is not equal on $($src.DisplayName)"
            }
        }
    }
}
