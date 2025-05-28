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

function New-VmsView {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.ViewGroup]
        $ViewGroup,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Position = 2)]
        [VideoOS.Platform.ConfigurationItems.Camera[]]
        $Cameras,

        [Parameter(ParameterSetName = 'Default')]
        [string]
        $StreamName,

        [Parameter(ParameterSetName = 'Custom')]
        [ValidateRange(1, 100)]
        [int]
        $Columns,

        [Parameter(ParameterSetName = 'Custom')]
        [ValidateRange(1, 100)]
        [int]
        $Rows,

        [Parameter(ParameterSetName = 'Advanced')]
        [string]
        $LayoutDefinitionXml,

        [Parameter(ParameterSetName = 'Advanced')]
        [string[]]
        $ViewItemDefinitionXml
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            if ($null -eq $ViewGroup.ViewFolder) {
                throw "Top-level view groups cannot contain views. Views may only be added to child view groups."
            }
            switch ($PSCmdlet.ParameterSetName) {
                'Default' { $LayoutDefinitionXml = New-VmsViewLayout -ViewItemCount $Cameras.Count }
                'Custom'  { $LayoutDefinitionXml = New-VmsViewLayout -Columns $Columns -Rows $Rows }
            }

            $invokeInfo = $ViewGroup.ViewFolder.AddView($LayoutDefinitionXml)
            if ($invokeInfo.State -ne 'Success') {
                throw $invokeInfo.ErrorText
            }
            $invokeInfo.SetProperty('Name', $Name)
            $invokeResult = $invokeInfo.ExecuteDefault()
            if ($invokeResult.State -ne 'Success') {
                throw $invokeResult.ErrorText
            }
            $ViewGroup.ViewFolder.ClearChildrenCache()
            $view = $ViewGroup.ViewFolder.Views | Where-Object Path -eq $invokeResult.Path
            $dirty = $false

            if ($PSCmdlet.ParameterSetName -ne 'Advanced') {
                $smartClientId = GetSmartClientId -View $view
                $i = 0
                if ($Cameras.Count -gt $view.ViewItemChildItems.Count) {
                    Write-Warning "The view is not large enough for the number of cameras selected. Only the first $($view.ViewItemChildItems.Count) of $($Cameras.Count) cameras will be included."
                }
                foreach ($cam in $Cameras) {
                    $streamId = [guid]::Empty
                    if (-not [string]::IsNullOrWhiteSpace($StreamName)) {
                        $stream = $cam | Get-VmsCameraStream | Where-Object DisplayName -eq $StreamName | Select-Object -First 1

                        if ($null -ne $stream) {
                            $streamId = $stream.StreamReferenceId
                        } else {
                            Write-Warning "Stream named ""$StreamName"" not found on $($cam.Name). Default live stream will be used instead."
                        }
                    }
                    $properties = $cam | New-VmsViewItemProperties -SmartClientId $smartClientId
                    $properties.LiveStreamId = $streamId
                    $viewItemDefinition = $properties | New-CameraViewItemDefinition
                    $view.ViewItemChildItems[$i++].SetProperty('ViewItemDefinitionXml', $viewItemDefinition)
                    $dirty = $true
                    if ($i -ge $view.ViewItemChildItems.Count) {
                        break
                    }
                }
            } else {
                for ($i = 0; $i -lt $ViewItemDefinitionXml.Count; $i++) {
                    $view.ViewItemChildItems[$i].SetProperty('ViewItemDefinitionXml', $ViewItemDefinitionXml[$i])
                    $dirty = $true
                }
            }

            if ($dirty) {
                $view.Save()
            }
            Write-Output $view
        } catch {
            Write-Error $_
        }
    }
}

function GetSmartClientId ($View) {
    $id = New-Guid
    if ($view.ViewItemChildItems[0].GetProperty('ViewItemDefinitionXml') -match 'smartClientId="(?<id>.{36})"') {
        $id = $Matches.id
    }
    Write-Output $id
}

