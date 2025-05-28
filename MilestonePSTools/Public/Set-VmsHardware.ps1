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

function Set-VmsHardware {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([VideoOS.Platform.ConfigurationItems.Hardware])]
    [Alias('Set-HardwarePassword')]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.Hardware[]]
        $Hardware,

        [Parameter()]
        [bool]
        $Enabled,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [uri]
        $Address,

        [Parameter()]
        [string]
        $UserName,

        [Parameter()]
        [Alias('NewPassword')]
        [ValidateVmsVersion('11.3')]
        [SecureStringTransformAttribute()]
        [ValidateScript({
            if ($_.Length -gt 64) {
                throw "The maximum password length is 64 characters. See Get-Help Set-VmsHardware -Online for more information."
            }
            $true
        })]
        [securestring]
        $Password,

        [Parameter()]
        [ValidateVmsVersion('23.2')]
        [switch]
        $UpdateRemoteHardware,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
        if ($UpdateRemoteHardware -and -not $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Password')) {
            Write-Warning "The UpdateRemoteHardware parameter is ignored because no value was provided for the Password parameter."
        }
    }

    process {
        foreach ($hw in $Hardware) {
            if ($MyInvocation.BoundParameters.ContainsKey('WhatIf') -and $WhatIf -eq $true) {
                # Operate on a separate hardware record to avoid modifying local properties when using WhatIf.
                $hw = Get-VmsHardware -Id $hw.Id
            }
            $initialName = $hw.Name
            $initialAddress = $hw.Address
            $dirty = $false

            foreach ($key in $MyInvocation.BoundParameters.Keys) {
                switch ($key) {
                    'Enabled' {
                        if ($Enabled -ne $hw.Enabled) {
                            Write-Verbose "Changing value of '$key' from $($hw.Enabled) to $Enabled on $initialName."
                            $hw.Enabled = $Enabled
                            $dirty = $true
                        }
                    }

                    'Name' {
                        if ($Name -cne $hw.Name) {
                            Write-Verbose "Changing value of '$key' from $($hw.Name) to $Name."
                            $hw.Name = $Name
                            $dirty = $true
                        }
                    }

                    'Address' {
                        if ($Address -ne [uri]$hw.Address) {
                            Write-Verbose "Changing value of '$key' from $($hw.Address) to $Address on $initialName."
                            $hw.Address = $Address
                            $dirty = $true
                        }
                    }

                    'UserName' {
                        if ($UserName -cne $hw.UserName) {
                            Write-Verbose "Changing value of '$key' from $($hw.UserName) to $UserName on $initialName."
                            $hw.UserName = $UserName
                            $dirty = $true
                        }
                    }

                    'Password' {
                        $action = "Change password in the VMS"
                        if ($UpdateRemoteHardware) {
                            $action += ' and on remote hardware device'
                        }
                        if ($PSCmdlet.ShouldProcess("$initialName", $action)) {
                            try {
                                $invokeResult = $hw.ChangePasswordHardware($Password, $UpdateRemoteHardware.ToBool())
                                if ($invokeResult.Path -match '^Task') {
                                    $invokeResult = $invokeResult | Wait-VmsTask -Title "Updating hardware password for $initialName"
                                }
                                if (($invokeResult.Properties | Where-Object Key -eq 'State').Value -eq 'Error') {
                                    Write-Error -Message "ChangePasswordHardware error: $(($invokeResult.Properties | Where-Object Key -eq 'ErrorText').Value)" -TargetObject $hw
                                }
                            } catch {
                                Write-Error -Message $_.Exception.Message -Exception $_.Exception -TargetObject $hw
                            }
                        }
                    }

                    'Description' {
                        if ($Description -cne $hw.Description) {
                            Write-Verbose "Changing value of '$key' on $initialName."
                            $hw.Description = $Description
                            $dirty = $true
                        }
                    }
                }
            }

            $target = "Hardware '$initialName' ($initialAddress)"
            if ($dirty) {
                if ($PSCmdlet.ShouldProcess($target, "Save changes")) {
                    try {
                        $hw.Save()
                    } catch [VideoOS.Platform.Proxy.ConfigApi.ValidateResultException] {
                        $errorResults = $_.Exception.InnerException.ValidateResult.ErrorResults
                        if ($null -eq $errorResults -or $errorResults.Count -eq 0) {
                            throw
                        }
                        foreach ($result in $errorResults) {
                            Write-Error -Message "Validation error on property '$($result.ErrorProperty)': $($result.ErrorText)"
                        }
                    } catch {
                        Write-Error -ErrorRecord $_ -Exception $_.Exception -TargetObject $hw
                    }
                }
            }

            if ($PassThru) {
                $hw
            }
        }
    }
}

