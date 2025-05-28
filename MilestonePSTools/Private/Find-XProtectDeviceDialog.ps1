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

function Find-XProtectDeviceDialog {
    [CmdletBinding()]
    [RequiresInteractiveSession()]
    param ()

    begin {
        Assert-VmsRequirementsMet
    }
    
    process {
        Add-Type -AssemblyName PresentationFramework
        $xaml = [xml]@"
        <Window
                xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
                xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
                xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
                xmlns:local="clr-namespace:Search_XProtect"
                Title="Search XProtect" Height="500" Width="800"
                FocusManager.FocusedElement="{Binding ElementName=cboItemType}">
            <Grid>
                <GroupBox Name="gboAdvanced" Header="Advanced Parameters" HorizontalAlignment="Left" Height="94" Margin="506,53,0,0" VerticalAlignment="Top" Width="243"/>
                <Label Name="lblItemType" Content="Item Type" HorizontalAlignment="Left" Margin="57,22,0,0" VerticalAlignment="Top"/>
                <ComboBox Name="cboItemType" HorizontalAlignment="Left" Margin="124,25,0,0" VerticalAlignment="Top" Width="120" TabIndex="0">
                    <ComboBoxItem Content="Camera" HorizontalAlignment="Left" Width="118"/>
                    <ComboBoxItem Content="Hardware" HorizontalAlignment="Left" Width="118"/>
                    <ComboBoxItem Content="InputEvent" HorizontalAlignment="Left" Width="118"/>
                    <ComboBoxItem Content="Metadata" HorizontalAlignment="Left" Width="118"/>
                    <ComboBoxItem Content="Microphone" HorizontalAlignment="Left" Width="118"/>
                    <ComboBoxItem Content="Output" HorizontalAlignment="Left" Width="118"/>
                    <ComboBoxItem Content="Speaker" HorizontalAlignment="Left" Width="118"/>
                </ComboBox>
                <Label Name="lblName" Content="Name" HorizontalAlignment="Left" Margin="77,53,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                <Label Name="lblPropertyName" Content="Property Name" HorizontalAlignment="Left" Margin="519,80,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                <ComboBox Name="cboPropertyName" HorizontalAlignment="Left" Margin="614,84,0,0" VerticalAlignment="Top" Width="120" IsEnabled="False" TabIndex="5"/>
                <TextBox Name="txtName" HorizontalAlignment="Left" Height="23" Margin="124,56,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="187" IsEnabled="False" TabIndex="1"/>
                <Button Name="btnSearch" Content="Search" HorizontalAlignment="Left" Margin="306,154,0,0" VerticalAlignment="Top" Width="75" TabIndex="7" IsEnabled="False"/>
                <DataGrid Name="dgrResults" HorizontalAlignment="Left" Height="207" Margin="36,202,0,0" VerticalAlignment="Top" Width="719" IsReadOnly="True"/>
                <Label Name="lblAddress" Content="IP Address" HorizontalAlignment="Left" Margin="53,84,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                <TextBox Name="txtAddress" HorizontalAlignment="Left" Height="23" Margin="124,87,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120" IsEnabled="False" TabIndex="2"/>
                <Label Name="lblEnabledFilter" Content="Enabled/Disabled" HorizontalAlignment="Left" Margin="506,22,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                <ComboBox Name="cboEnabledFilter" HorizontalAlignment="Left" Margin="614,26,0,0" VerticalAlignment="Top" Width="120" IsEnabled="False" TabIndex="4">
                    <ComboBoxItem Content="Enabled" HorizontalAlignment="Left" Width="118"/>
                    <ComboBoxItem Content="Disabled" HorizontalAlignment="Left" Width="118"/>
                    <ComboBoxItem Name="cbiEnabledAll" Content="All" HorizontalAlignment="Left" Width="118" IsSelected="True"/>
                </ComboBox>
                <Label Name="lblMACAddress" Content="MAC Address" HorizontalAlignment="Left" Margin="37,115,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                <TextBox Name="txtMACAddress" HorizontalAlignment="Left" Height="23" Margin="124,118,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120" IsEnabled="False" TabIndex="3"/>
                <Label Name="lblPropertyValue" Content="Property Value" HorizontalAlignment="Left" Margin="522,108,0,0" VerticalAlignment="Top" IsEnabled="False"/>
                <TextBox Name="txtPropertyValue" HorizontalAlignment="Left" Height="23" Margin="614,111,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="120" IsEnabled="False" TabIndex="6"/>
                <Button Name="btnExportCSV" Content="Export CSV" HorizontalAlignment="Left" Margin="680,429,0,0" VerticalAlignment="Top" Width="75" TabIndex="9" IsEnabled="False"/>
                <Label Name="lblNoResults" Content="No results found!" HorizontalAlignment="Left" Margin="345,175,0,0" VerticalAlignment="Top" Foreground="Red" Visibility="Hidden"/>
                <Button Name="btnResetForm" Content="Reset Form" HorizontalAlignment="Left" Margin="414,154,0,0" VerticalAlignment="Top" Width="75" TabIndex="8"/>
                <Label Name="lblTotalResults" Content="Total Results:" HorizontalAlignment="Left" Margin="32,423,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
                <TextBox Name="txtTotalResults" HorizontalAlignment="Left" Height="23" Margin="120,427,0,0" VerticalAlignment="Top" Width="53" IsEnabled="False"/>
                <Label Name="lblPropertyNameBlank" Content="Property Name cannot be blank if Property&#xD;&#xA;Value has an entry." HorizontalAlignment="Left" Margin="507,152,0,0" VerticalAlignment="Top" Foreground="Red" Width="248" Height="45" Visibility="Hidden"/>
                <Label Name="lblPropertyValueBlank" Content="Property Value cannot be blank if Property&#xA;Name has a selection." HorizontalAlignment="Left" Margin="507,152,0,0" VerticalAlignment="Top" Foreground="Red" Width="248" Height="45" Visibility="Hidden"/>
            </Grid>
        </Window>
"@

        function Clear-Results {
            $var_dgrResults.Columns.Clear()
            $var_dgrResults.Items.Clear()
            $var_txtTotalResults.Clear()
            $var_lblNoResults.Visibility = "Hidden"
            $var_lblPropertyNameBlank.Visibility = "Hidden"
            $var_lblPropertyValueBlank.Visibility = "Hidden"
        }

        $reader = [system.xml.xmlnodereader]::new($xaml)
        $window = [windows.markup.xamlreader]::Load($reader)
        $searchResults = $null

        # Create variables based on form control names.
        # Variable will be named as 'var_<control name>'
        $xaml.SelectNodes("//*[@Name]") | ForEach-Object {
            try {
                Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
            } catch {
                throw
            }
        }

        $iconBase64 = "AAABAAEAICAAAAEAIACoEAAAFgAAACgAAAAgAAAAQAAAAAEAIAAAAAAAABAAAMMOAADDDgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADamQCA2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA2pkAgNqZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADamQCA2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA2pkAgNqZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADamQCA2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA2pkAgNqZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADamQCA2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA2pkAgNqZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADamQCA2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAA2pkAgNqZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAADamQCA2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgNqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQCAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAIAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQD/2pkA/9qZAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkA/9qZAP/amQCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAP/amQD/2pkAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQD/2pkA/9qZAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANqZAIDamQCAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//5////8P///+B////AP///gB///wAP//4AB//8AAP/+AAB//AAAP/gAAB/wAAAP4AAAB8AAAAOAAAABAAAAAAAAAACAAAABwAAAA+AAAAfwAAAP+AAAH/wAAD/+AAB//wAA//+AAf//wAP//+AH///wD///+B////w////+f/8="
        $iconBytes = [Convert]::FromBase64String($iconBase64)
        $window.Icon = $iconBytes

        $assembly = [System.Reflection.Assembly]::GetAssembly([VideoOS.Platform.ConfigurationItems.Hardware])

        $excludedItems = "Folder|Path|Icon|Enabled|DisplayName|RecordingFramerate|ItemCategory|Wrapper|Address|Channel"

        $var_cboItemType.Add_SelectionChanged( {
                param($sender, $e)
                $itemType = $e.AddedItems[0].Content

                $var_cboPropertyName.Items.Clear()
                $var_dgrResults.Columns.Clear()
                $var_dgrResults.Items.Clear()
                $var_txtTotalResults.Clear()
                $var_txtPropertyValue.Clear()
                $var_lblNoResults.Visibility = "Hidden"
                $var_lblPropertyNameBlank.Visibility = "Hidden"
                $var_lblPropertyValueBlank.Visibility = "Hidden"

                $properties = ($assembly.GetType("VideoOS.Platform.ConfigurationItems.$itemType").DeclaredProperties | Where-Object { $_.PropertyType.Name -eq 'String' }).Name + ([VideoOS.Platform.ConfigurationItems.IConfigurationChildItem].DeclaredProperties | Where-Object { $_.PropertyType.Name -eq 'String' }).Name | Where-Object { $_ -notmatch $excludedItems }
                foreach ($property in $properties) {
                    $newComboboxItem = [System.Windows.Controls.ComboBoxItem]::new()
                    $newComboboxItem.AddChild($property)
                    $var_cboPropertyName.Items.Add($newComboboxItem)
                }

                $sortDescription = [System.ComponentModel.SortDescription]::new("Content", "Ascending")
                $var_cboPropertyName.Items.SortDescriptions.Add($sortDescription)

                $var_cboEnabledFilter.IsEnabled = $true
                $var_lblEnabledFilter.IsEnabled = $true
                $var_cboPropertyName.IsEnabled = $true
                $var_lblPropertyName.IsEnabled = $true
                $var_txtPropertyValue.IsEnabled = $true
                $var_lblPropertyValue.IsEnabled = $true
                $var_txtName.IsEnabled = $true
                $var_lblName.IsEnabled = $true
                $var_btnSearch.IsEnabled = $true

                if ($itemType -eq "Hardware") {
                    $var_txtAddress.IsEnabled = $true
                    $var_lblAddress.IsEnabled = $true
                    $var_txtMACAddress.IsEnabled = $true
                    $var_lblMACAddress.IsEnabled = $true
                } else {
                    $var_txtAddress.IsEnabled = $false
                    $var_txtAddress.Clear()
                    $var_lblAddress.IsEnabled = $false
                    $var_txtMACAddress.IsEnabled = $false
                    $var_txtMACAddress.Clear()
                    $var_lblMACAddress.IsEnabled = $false
                }
            })

        $var_txtName.Add_TextChanged( {
                Clear-Results
            })

        $var_txtAddress.Add_TextChanged( {
                Clear-Results
            })

        $var_txtMACAddress.Add_TextChanged( {
                Clear-Results
            })

        $var_cboEnabledFilter.Add_SelectionChanged( {
                Clear-Results
            })

        $var_cboPropertyName.Add_SelectionChanged( {
                Clear-Results
            })

        $var_txtPropertyValue.Add_TextChanged( {
                Clear-Results
            })

        $var_btnSearch.Add_Click( {
                if (-not [string]::IsNullOrEmpty($var_cboPropertyName.Text) -and [string]::IsNullOrEmpty($var_txtPropertyValue.Text)) {
                    $var_lblPropertyValueBlank.Visibility = "Visible"
                    Return
                } elseif ([string]::IsNullOrEmpty($var_cboPropertyName.Text) -and -not [string]::IsNullOrEmpty($var_txtPropertyValue.Text)) {
                    $var_lblPropertyNameBlank.Visibility = "Visible"
                    Return
                }

                $script:searchResults = Find-XProtectDeviceSearch -ItemType $var_cboItemType.Text -Name $var_txtName.Text -Address $var_txtAddress.Text -MAC $var_txtMACAddress.Text -Enabled $var_cboEnabledFilter.Text -PropertyName $var_cboPropertyName.Text -PropertyValue $var_txtPropertyValue.Text
                if ($null -ne $script:searchResults) {
                    $var_btnExportCSV.IsEnabled = $true
                } else {
                    $var_btnExportCSV.IsEnabled = $false
                }
            })

        $var_btnExportCSV.Add_Click( {
                $saveDialog = New-Object Microsoft.Win32.SaveFileDialog
                $saveDialog.Title = "Save As CSV"
                $saveDialog.Filter = "Comma delimited (*.csv)|*.csv"

                $saveAs = $saveDialog.ShowDialog()

                if ($saveAs -eq $true) {
                    $script:searchResults | Export-Csv -Path $saveDialog.FileName -NoTypeInformation
                }
            })

        $var_btnResetForm.Add_Click( {
                $var_dgrResults.Columns.Clear()
                $var_dgrResults.Items.Clear()
                $var_cboItemType.SelectedItem = $null
                $var_cboEnabledFilter.IsEnabled = $false
                $var_lblEnabledFilter.IsEnabled = $false
                $var_cbiEnabledAll.IsSelected = $true
                $var_cboPropertyName.IsEnabled = $false
                $var_cboPropertyName.Items.Clear()
                $var_lblPropertyName.IsEnabled = $false
                $var_txtPropertyValue.IsEnabled = $false
                $var_txtPropertyValue.Clear()
                $var_lblPropertyValue.IsEnabled = $false
                $var_txtName.IsEnabled = $false
                $var_txtName.Clear()
                $var_lblName.IsEnabled = $false
                $var_btnSearch.IsEnabled = $false
                $var_btnExportCSV.IsEnabled = $false
                $var_txtAddress.IsEnabled = $false
                $var_txtAddress.Clear()
                $var_lblAddress.IsEnabled = $false
                $var_txtMACAddress.IsEnabled = $false
                $var_txtMACAddress.Clear()
                $var_lblMACAddress.IsEnabled = $false
                $var_txtTotalResults.Clear()
                $var_lblNoResults.Visibility = "Hidden"
                $var_lblPropertyNameBlank.Visibility = "Hidden"
                $var_lblPropertyValueBlank.Visibility = "Hidden"
            })

        $null = $window.ShowDialog()
    }
}

function Find-XProtectDeviceSearch {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ItemType,
        [Parameter(Mandatory = $false)]
        [string]$Name,
        [Parameter(Mandatory = $false)]
        [string]$Address,
        [Parameter(Mandatory = $false)]
        [string]$MAC,
        [Parameter(Mandatory = $false)]
        [string]$Enabled,
        [Parameter(Mandatory = $false)]
        [string]$PropertyName,
        [Parameter(Mandatory = $false)]
        [string]$PropertyValue
    )

    process {
        $var_dgrResults.Columns.Clear()
        $var_dgrResults.Items.Clear()
        $var_lblNoResults.Visibility = "Hidden"
        $var_lblPropertyNameBlank.Visibility = "Hidden"
        $var_lblPropertyValueBlank.Visibility = "Hidden"

        if ([string]::IsNullOrEmpty($PropertyName) -or [string]::IsNullOrEmpty($PropertyValue)) {
            $PropertyName = "Id"
            $PropertyValue = $null
        }

        if ($ItemType -eq "Hardware" -and $null -eq [string]::IsNullOrEmpty($MAC)) {
            $results = [array](Find-XProtectDevice -ItemType $ItemType -MacAddress $MAC -EnableFilter $Enabled -Properties @{Name = $Name; Address = $Address; $PropertyName = $PropertyValue })
        } elseif ($ItemType -eq "Hardware" -and $null -ne [string]::IsNullOrEmpty($MAC)) {
            $results = [array](Find-XProtectDevice -ItemType $ItemType -EnableFilter $Enabled -Properties @{Name = $Name; Address = $Address; $PropertyName = $PropertyValue })
        } else {
            $results = [array](Find-XProtectDevice -ItemType $ItemType -EnableFilter $Enabled -Properties @{Name = $Name; $PropertyName = $PropertyValue })
        }

        if ($null -ne $results) {
            $columnNames = $results[0].PsObject.Properties | ForEach-Object { $_.Name }
        } else {
            $var_lblNoResults.Visibility = "Visible"
        }

        foreach ($columnName in $columnNames) {
            $newColumn = [System.Windows.Controls.DataGridTextColumn]::new()
            $newColumn.Header = $columnName
            $newColumn.Binding = New-Object System.Windows.Data.Binding($columnName)
            $newColumn.Width = "SizeToCells"
            $var_dgrResults.Columns.Add($newColumn)
        }

        if ($ItemType -eq "Hardware") {
            foreach ($result in $results) {
                $var_dgrResults.AddChild([pscustomobject]@{Hardware = $result.Hardware; RecordingServer = $result.RecordingServer })
            }
        } else {
            foreach ($result in $results) {
                $var_dgrResults.AddChild([pscustomobject]@{$columnNames[0] = $result.((Get-Variable -Name columnNames).Value[0]); Hardware = $result.Hardware; RecordingServer = $result.RecordingServer })
            }
        }

        $var_txtTotalResults.Text = $results.count
    }
    end {
        return $results
    }
}

