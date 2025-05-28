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

function Import-VmsViewGroup {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.ViewGroup])]
    param(
        [Parameter(Mandatory)]
        [string]
        $Path,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $NewName,

        [Parameter()]
        [ValidateNotNull()]
        [VideoOS.Platform.ConfigurationItems.ViewGroup]
        $ParentViewGroup
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        [environment]::CurrentDirectory = Get-Location
        $Path = [io.path]::GetFullPath($Path)

        $source = [io.file]::ReadAllText($Path) | ConvertFrom-Json -ErrorAction Stop
        if ($source.ItemType -ne 'ViewGroup') {
            throw "Invalid file specified in Path parameter. File must be in JSON format and the root object must have an ItemType value of ViewGroup."
        }
        if ($MyInvocation.BoundParameters.ContainsKey('NewName')) {
            ($source.Properties | Where-Object Key -eq 'Name').Value = $NewName
        }
        $params = @{
            Source = $source
        }
        if ($MyInvocation.BoundParameters.ContainsKey('ParentViewGroup')) {
            $params.ParentViewGroup = $ParentViewGroup
        }
        Copy-ViewGroupFromJson @params
    }
}

