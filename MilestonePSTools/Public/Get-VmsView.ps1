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

function Get-VmsView {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('21.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.View])]
    param (
        [Parameter(ValueFromPipeline, ParameterSetName = 'Default')]
        [VideoOS.Platform.ConfigurationItems.ViewGroup[]]
        $ViewGroup,

        [Parameter(ParameterSetName = 'Default', Position = 1)]
        [ArgumentCompleter([MilestonePSTools.Utility.MipItemNameCompleter[VideoOS.Platform.ConfigurationItems.View]])]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]
        $Name = '*',

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'ById', Position = 2)]
        [guid]
        $Id
    )

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'Default' {
                if ($null -eq $ViewGroup) {
                    $ViewGroup = Get-VmsViewGroup -Recurse
                }
                $count = 0
                foreach ($vg in $ViewGroup) {
                    foreach ($view in $vg.ViewFolder.Views) {
                        if ($view.Path -in $vg.ViewGroupFolder.ViewGroups.ViewFolder.Views.Path) {
                            # TODO: Remove this someday when bug 479533 is no longer an issue.
                            Write-Verbose "Ignoring duplicate view caused by configuration api issue resolved in later VMS versions."
                            continue
                        }
                        foreach ($n in $Name) {
                            if ($view.DisplayName -like $n) {
                                Write-Output $view
                                $count++
                            }
                        }
                    }
                }

                if ($count -eq 0 -and -not [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Name)) {
                    Write-Error "View ""$Name"" not found."
                }
            }

            'ById' {
                $path = 'View[{0}]' -f $Id.ToString().ToUpper()
                Write-Output ([VideoOS.Platform.ConfigurationItems.View]::new((Get-VmsSite).FQID.ServerId, $path))
            }
        }
    }
}

function ViewArgumentCompleter{
    param ( $commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters )

    if ($fakeBoundParameters.ContainsKey('ViewGroup')) {
        $folder = $fakeBoundParameters.ViewGroup.ViewFolder
        $possibleValues = $folder.Views.Name
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
}

Register-ArgumentCompleter -CommandName Get-VmsView -ParameterName Name -ScriptBlock (Get-Command ViewArgumentCompleter).ScriptBlock

