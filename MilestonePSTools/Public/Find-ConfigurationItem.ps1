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

function Find-ConfigurationItem {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    param (
        # Specifies all, or part of the display name of the configuration item to search for. For example, if you want to find a camera named "North West Parking" and you specify the value 'Parking', you will get results for any camera where 'Parking' appears in the name somewhere. The search is not case sensitive.
        [Parameter()]
        [string]
        $Name,

        # Specifies the type(s) of items to include in the results. The default is to include only 'Camera' items.
        [Parameter()]
        [string[]]
        $ItemType = 'Camera',

        # Specifies whether all matching items should be included, or whether only enabled, or disabled items should be included in the results. The default is to include all items regardless of state.
        [Parameter()]
        [ValidateSet('All', 'Disabled', 'Enabled')]
        [string]
        $EnableFilter = 'All',

        # An optional hashtable of additional property keys and values to filter results. Properties must be string types, and the results will be included if the property key exists, and the value contains the provided string.
        [Parameter()]
        [hashtable]
        $Properties = @{}
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        $svc = Get-IConfigurationService -ErrorAction Stop
        $itemFilter = [VideoOS.ConfigurationApi.ClientService.ItemFilter]::new()
        $itemFilter.EnableFilter = [VideoOS.ConfigurationApi.ClientService.EnableFilter]::$EnableFilter

        $propertyFilters = New-Object System.Collections.Generic.List[VideoOS.ConfigurationApi.ClientService.PropertyFilter]
        if (-not [string]::IsNullOrWhiteSpace($Name) -and $Name -ne '*') {
            $Properties.Name = $Name
        }
        foreach ($key in $Properties.Keys) {
            $propertyFilters.Add([VideoOS.ConfigurationApi.ClientService.PropertyFilter]::new(
                    $key,
                    [VideoOS.ConfigurationApi.ClientService.Operator]::Contains,
                    $Properties.$key
                ))
        }
        $itemFilter.PropertyFilters = $propertyFilters

        foreach ($type in $ItemType) {
            $itemFilter.ItemType = $type
            $svc.QueryItems($itemFilter, [int]::MaxValue) | Foreach-Object {
                Write-Output $_
            }
        }
    }
}

$ItemTypeArgCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    ([VideoOS.ConfigurationAPI.ItemTypes] | Get-Member -Static -MemberType Property).Name | Where-Object {
        $_ -like "$wordToComplete*"
    } | Foreach-Object {
        "'$_'"
    }
}
Register-ArgumentCompleter -CommandName Find-ConfigurationItem -ParameterName ItemType -ScriptBlock $ItemTypeArgCompleter
Register-ArgumentCompleter -CommandName ConvertFrom-ConfigurationItem -ParameterName ItemType -ScriptBlock $ItemTypeArgCompleter

