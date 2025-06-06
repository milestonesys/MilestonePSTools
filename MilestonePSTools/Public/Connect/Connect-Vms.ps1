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

function Connect-Vms {
    [CmdletBinding(DefaultParameterSetName = 'ConnectionProfile')]
    [OutputType([VideoOS.Platform.ConfigurationItems.ManagementServer])]
    [RequiresVmsConnection($false)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification='The noun is an acronym.')]
    param (
        [Parameter(ParameterSetName = 'ConnectionProfile', ValueFromPipelineByPropertyName, Position = 0)]
        [Parameter(ParameterSetName = 'ServerAddress')]
        [Parameter(ParameterSetName = 'ShowDialog')]
        [string]
        $Name = 'default',

        [Parameter(ParameterSetName = 'ShowDialog', ValueFromPipelineByPropertyName)]
        [RequiresInteractiveSession()]
        [switch]
        $ShowDialog,

        [Parameter(ParameterSetName = 'ServerAddress', Mandatory, ValueFromPipelineByPropertyName)]
        [uri]
        $ServerAddress,

        [Parameter(ParameterSetName = 'ServerAddress', ValueFromPipelineByPropertyName)]
        [pscredential]
        $Credential,

        [Parameter(ParameterSetName = 'ServerAddress', ValueFromPipelineByPropertyName)]
        [switch]
        $BasicUser,

        [Parameter(ParameterSetName = 'ServerAddress', ValueFromPipelineByPropertyName)]
        [switch]
        $SecureOnly,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        $IncludeChildSites,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        $AcceptEula,

        [Parameter(ParameterSetName = 'ConnectionProfile')]
        [switch]
        $NoProfile
    )

    begin {
        Assert-VmsRequirementsMet
    }
        
    process {
        Disconnect-Vms
        
        switch ($PSCmdlet.ParameterSetName) {
            'ConnectionProfile' {
                $vmsProfile = GetVmsConnectionProfile -Name $Name
                if ($vmsProfile) {
                    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('IncludeChildSites')) {
                        $vmsProfile['IncludeChildSites'] = $IncludeChildSites
                    }
                    Connect-ManagementServer @vmsProfile -Force -ErrorAction Stop
                } else {
                    Connect-ManagementServer -ShowDialog -AcceptEula:$AcceptEula -IncludeChildSites:$IncludeChildSites -Force -ErrorAction Stop
                }
            }

            'ServerAddress' {
                $connectArgs = @{
                    ServerAddress     = $ServerAddress
                    SecureOnly        = $SecureOnly
                    IncludeChildSites = $IncludeChildSites
                    AcceptEula        = $AcceptEula
                }
                if ($Credential) {
                    $connectArgs.Credential = $Credential
                    $connectArgs.BasicUser = $BasicUser
                }
                Connect-ManagementServer @connectArgs -ErrorAction Stop
            }

            'ShowDialog' {
                if ($ShowDialog) {
                    $connectArgs = @{
                        ShowDialog        = $ShowDialog
                        IncludeChildSites = $IncludeChildSites
                        AcceptEula        = $AcceptEula
                    }
                    Connect-ManagementServer @connectArgs -ErrorAction Stop
                }
            }

            Default {
                throw "ParameterSetName '$_' not implemented."
            }
        }

        if (Test-VmsConnection) {
            if (-not $NoProfile -and ($PSCmdlet.ParameterSetName -eq 'ConnectionProfile' -or $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Name'))) {
                Save-VmsConnectionProfile -Name $Name -Force
            }
            
            Get-VmsManagementServer
        }
    }
}

Register-ArgumentCompleter -CommandName Connect-Vms, Get-VmsConnectionProfile, Save-VmsConnectionProfile, Remove-VmsConnectionProfile -ParameterName Name -ScriptBlock {
    $options = (GetVmsConnectionProfile -All).Keys | Sort-Object
    if ([string]::IsNullOrWhiteSpace($args[2])) {
        $wordToComplete = '*'
    } else {
        $wordToComplete = $args[2].Trim('''').Trim('"')
    }

    $options | ForEach-Object {
        if ($_ -like "$wordToComplete*") {
            if ($_ -match '\s') {
                "'$_'"
            } else {
                $_
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Connect-Vms -ParameterName ServerAddress -ScriptBlock {
    $options = (GetVmsConnectionProfile -All).Values | ForEach-Object { $_.ServerAddress.ToString() } | Sort-Object
    if ([string]::IsNullOrWhiteSpace($args[2])) {
        $wordToComplete = '*'
    } else {
        $wordToComplete = $args[2].Trim('''').Trim('"')
    }

    $options | ForEach-Object {
        if ($_ -like "$wordToComplete*") {
            if ($_ -match '\s') {
                "'$_'"
            } else {
                $_
            }
        }
    }
}
