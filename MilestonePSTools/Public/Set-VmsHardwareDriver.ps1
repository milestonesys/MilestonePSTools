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

function Set-VmsHardwareDriver {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [RequiresVmsConnection()]
    [RequiresVmsVersion('23.1')]
    [OutputType([VideoOS.Platform.ConfigurationItems.Hardware])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter([MipItemNameCompleter[Hardware]])]
        [MipItemTransformation([Hardware])]
        [Hardware[]]
        $Hardware,

        [Parameter()]
        [uri]
        $Address,

        [Parameter()]
        [pscredential]
        $Credential,

        [Parameter()]
        [HardwareDriverTransformAttribute()]
        [VideoOS.Platform.ConfigurationItems.HardwareDriver]
        $Driver,

        [Parameter()]
        [string]
        $CustomDriverData,

        [Parameter()]
        [switch]
        $AllowDeletingDisabledDevices,

        [Parameter()]
        [switch]
        $PassThru
    )

    begin {
        Assert-VmsRequirementsMet
        $tasks = [system.collections.generic.list[VideoOS.ConfigurationApi.ClientService.ConfigurationItem]]::new()
        $taskInfo = @{}
        $recorderPathByHwPath = @{}
    }

    process {
        $hwParams = @{
            AllowDeletingDisabledDevices = $AllowDeletingDisabledDevices.ToString()
        }

        if ($MyInvocation.BoundParameters.ContainsKey('Address')) {
            if ($Address.Scheme -notin 'https', 'http') {
                Write-Error "Address must be in the format http://address or https://address"
                return
            }
            $hwParams.Address   = $Address.Host
            $hwParams.Port      = if ($Address.Scheme -eq 'http') { $Address.Port } else { 80 }
            $hwParams.UseHttps  = if ($Address.Scheme -eq 'https') { 'True' } else { 'False' }
            $hwParams.HttpsPort = if ($Address.Scheme -eq 'https') { $Address.Port } else { 443 }
        }

        if ($MyInvocation.BoundParameters.ContainsKey('Credential')) {
            $hwParams.UserName = $Credential.UserName
            $hwParams.Password = $Credential.GetNetworkCredential().Password
        } else {
            $hwParams.UserName = $Hardware.UserName
            $hwParams.Password = $Hardware | Get-VmsHardwarePassword
        }

        if ($MyInvocation.BoundParameters.ContainsKey('Driver')) {
            $hwParams.Driver = $Driver.Number.ToString()
        }

        if ($MyInvocation.BoundParameters.ContainsKey('CustomDriverData')) {
            $hwParams.CustomDriverData = $CustomDriverData
        }

        foreach ($hw in $Hardware) {
            if ($PSCmdlet.ShouldProcess("$($hw.Name) ($($hw.Address))", "Replace hardware")) {
                $recorderPathByHwPath[$hw.Path] = [videoos.platform.proxy.ConfigApi.ConfigurationItemPath]::new($hw.ParentItemPath)
                $method = 'ReplaceHardware'
                $item = $hw | Get-ConfigurationItem
                if ($method -notin $item.MethodIds) {
                    throw "The $method MethodId is not present. This method was introduced in XProtect VMS version 2023 R1."
                }
                $invokeInfo = $item | Invoke-Method -MethodId $method

                foreach ($key in $hwParams.Keys) {
                    if ($prop = $invokeInfo.Properties | Where-Object Key -eq $key) {
                        $prop.Value = $hwParams[$key]
                    }
                }

                Write-Verbose "ReplaceHardware task properties`r`n$($invokeInfo.Properties | Select-Object Key, @{Name = 'Value'; Expression = {if ($_.Key -eq 'Password') {'*' * 8} else {$_.Value}}} | Out-String)"
                $invokeResult = $invokeInfo | Invoke-Method ReplaceHardware
                $taskPath = ($invokeResult.Properties | Where-Object Key -eq 'Path').Value
                $tasks.Add((Get-ConfigurationItem -Path $taskPath))
                $taskInfo[$taskPath] = @{
                    HardwareName = $hw.Name
                    HardwarePath = [videoos.platform.proxy.ConfigApi.ConfigurationItemPath]::new($hw.Path)
                    RecorderPath = $recorderPathByHwPath[$hw.Path]
                    Task         = $null
                }
            }
        }
    }

    end {
        $recorders = @{}
        $replacedHardwarePaths = [system.collections.generic.list[string]]::new()
        foreach ($task in $tasks) {
            $task = $task | Wait-VmsTask -Cleanup
            if (($task.Properties | Where-Object Key -eq 'State').Value -ne 'Success') {
                $info = $taskInfo[$task.Path]
                $info.Task = $task
                $message = "Unknown error during ReplaceHardware for $($info.HardwareName) ($info.HardwarePath.Id)."
                $taskError = ($task.Properties | Where-Object Key -eq 'ErrorText').Value
                if (-not [string]::IsNullOrWhiteSpace($taskError)) {
                    $message = $taskError
                }
                Write-Error -Message $message -TargetObject ([ReplaceHardwareTaskInfo]$info)
            } else {
                $hwPath = ($task.Properties | Where-Object Key -eq 'HardwareId').Value
                $recPath = $recorderPathByHwPath[$hwPath]
                if (-not $recorders.ContainsKey($recPath.Id)) {
                    $recorders[$recPath.Id] = Get-VmsRecordingServer -Id $recPath.Id
                }
                $replacedHardwarePaths.Add($hwPath)
            }
        }
        foreach ($rec in $recorders.Values) {
            $rec.HardwareFolder.ClearChildrenCache()
        }
        if ($PassThru) {
            foreach ($path in $replacedHardwarePaths) {
                $itemPath = [videoos.platform.proxy.ConfigApi.ConfigurationItemPath]::new($path)
                Get-VmsHardware -HardwareId $itemPath.Id
            }
        }
    }
}

Register-ArgumentCompleter -CommandName Set-VmsHardwareDriver -ParameterName Driver -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    $values = Get-VmsRecordingServer | Select-Object -First 1 | Get-VmsHardwareDriver |
        Where-Object Name -like "$wordToComplete*" |
        Sort-Object Name |
        Select-Object -ExpandProperty Name -Unique
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

