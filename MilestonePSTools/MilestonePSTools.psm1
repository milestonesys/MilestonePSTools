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

<#
Functions in this module are written as independent PS1 files, and to improve module load time they
are "compiled" into this PSM1 file. If you're looking at this file prior to build, now you know how
all the functions will be loaded later. If you're looking at this file after build, now you know
why this file has so many lines :)
#>

#region Argument Completers
# The default place for argument completers is within the same .PS1 as the function
# but argument completers for C# cmdlets can be placed here if needed.

Register-ArgumentCompleter -CommandName Get-VmsSite, Select-VmsSite -ParameterName Name -ScriptBlock {
    $values = (Get-VmsSite -ListAvailable).Name | Sort-Object
    Complete-SimpleArgument -Arguments $args -ValueSet $values
}

Register-ArgumentCompleter -CommandName Start-Export -ParameterName Codec -ScriptBlock {
    $location = [environment]::CurrentDirectory
    try {
        Push-Location -Path $MipSdkPath
        [environment]::CurrentDirectory = $MipSdkPath
        $exporter = [VideoOS.Platform.Data.AVIExporter]::new()
        $values = $exporter.CodecList | Sort-Object
        Complete-SimpleArgument -Arguments $args -ValueSet $values
    } finally {
        [environment]::CurrentDirectory = $location
        Pop-Location
        if ($exporter) {
            $exporter.Close()
        }
    }
}


#endregion

# Enable the use of any TLS protocol version greater than or equal to TLS 1.2
$protocol = [Net.SecurityProtocolType]::SystemDefault
[enum]::GetNames([Net.SecurityProtocolType]) | Where-Object {
    # Match any TLS version greater than 1.1
            ($_ -match 'Tls(\d)(\d+)?') -and ([version]("$($Matches[1]).$([int]$Matches[2])")) -gt 1.1
} | ForEach-Object { $protocol = $protocol -bor [Net.SecurityProtocolType]::$_ }
[Net.ServicePointManager]::SecurityProtocol = $protocol

$script:Deprecations = Import-PowerShellDataFile -Path "$PSScriptRoot\deprecations.psd1"
$script:Messages = @{}
Import-LocalizedData -BindingVariable 'script:Messages' -FileName 'messages'
Export-ModuleMember -Cmdlet * -Alias * -Function *

if ((Get-VmsModuleConfig).Mip.ConfigurationApiManager.UseRestApiWhenAvailable) {
    Write-Warning @'

Experimental Feature: UseRestApiWhenAvailable
MilestonePSTools is configured to use the API Gateway REST API when available. Some features may not yet be implemented in the API Gateway.
If you experience unexpected errors, try disabling this behavior with the following commands:

  $config = Get-VmsModuleConfig
  $config.Mip.ConfigurationApiManager.UseRestApiWhenAvailable = $false
  $config | Set-VmsModuleConfig

'@
}

if ((Get-VmsModuleConfig).ApplicationInsights.Enabled -and -not [MilestonePSTools.Telemetry.AppInsightsTelemetry]::HasDisplayedTelemetryNotice) {
    $null = New-Item -ItemType Directory -Path ([MilestonePSTools.Module]::AppDataDirectory) -Force -ErrorAction Ignore
    (Get-Date).ToUniversalTime().ToString('o') | Set-Content -Path (Join-Path ([MilestonePSTools.Module]::AppDataDirectory) "telemetry_notice_displayed.txt") -ErrorAction Ignore
    Write-Host @'
MilestonePSTools may send telemetry data using Azure Application Insights. This
data is anonymous and helps us to prioritize new features, fixes, and
performance improvements.

You may opt-out using the command `Set-VmsModuleConfig -EnableTelemetry $false`

Read more at https://www.milestonepstools.com/commands/en-US/about_Telemetry/
'@
}
