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

function Get-VmsViewGroup {
    [CmdletBinding()]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.ViewGroup])]
    param (
        [Parameter(ValueFromPipeline, ParameterSetName = 'Default')]
        [VideoOS.Platform.ConfigurationItems.ViewGroup]
        $Parent,

        [Parameter(ParameterSetName = 'Default', Position = 1)]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $Name = '*',

        [Parameter(ParameterSetName = 'Default')]
        [switch]
        $Recurse,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 2)]
        [guid]
        $Id
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            try {
                $vg = [VideoOS.Platform.ConfigurationItems.ViewGroup]::new((Get-VmsSite).FQID.ServerId, "ViewGroup[$Id]")
                Write-Output $vg
            } catch [System.Management.Automation.MethodInvocationException] {
                if ($_.FullyQualifiedErrorId -eq 'PathNotFoundMIPException') {
                    Write-Error "No ViewGroup found with ID matching $Id"
                    return
                }
            }
        } else {
            if ($null -ne $Parent) {
                $vgFolder = $Parent.ViewGroupFolder
            } else {
                $vgFolder = (Get-VmsManagementServer).ViewGroupFolder
            }

            $count = 0
            foreach ($vg in $vgFolder.ViewGroups) {
                foreach ($n in $Name) {
                    if ($vg.DisplayName -notlike $n) {
                        continue
                    }
                    $count++
                    if (-not $Recurse -or ($Recurse -and $Name -eq '*')) {
                        Write-Output $vg
                    }
                    if ($Recurse) {
                        $vg | Get-VmsViewGroup -Recurse
                    }
                    continue
                }
            }

            if ($count -eq 0 -and -not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Name)) {
                Write-Error "ViewGroup ""$Name"" not found."
            }
        }
    }
}

function ViewGroupArgumentCompleter{
    param ( $commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters )

    $folder = (Get-VmsManagementServer).ViewGroupFolder
    if ($fakeBoundParameters.ContainsKey('Parent')) {
        $folder = $fakeBoundParameters.Parent.ViewGroupFolder
    }

    $possibleValues = $folder.ViewGroups.DisplayName
    $wordToComplete = $wordToComplete.Trim("'").Trim('"')
    if (-not [string]::IsNullOrWhiteSpace($wordToComplete)) {
        $possibleValues = $possibleValues | Where-Object { $_ -like "$wordToComplete*" }
    }
    $possibleValues | Foreach-Object {
        if ($_ -like '* *') {
            "'$_'"
        } else {
            $_
        }
    }
}

Register-ArgumentCompleter -CommandName Get-VmsViewGroup -ParameterName Name -ScriptBlock (Get-Command ViewGroupArgumentCompleter).ScriptBlock

