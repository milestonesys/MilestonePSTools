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

function Get-ManagementServerConfig {
    [CmdletBinding()]
    [RequiresVmsConnection($false)]
    param()

    begin {
        Assert-VmsRequirementsMet
        $configXml = Join-Path ([system.environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData)) 'milestone\xprotect management server\serverconfig.xml'
        if (-not (Test-Path $configXml)) {
            throw [io.filenotfoundexception]::new('Management Server configuration file not found', $configXml)
        }
    }

    process {
        $xml = [xml](Get-Content -Path $configXml)
        
        $versionNode = $xml.SelectSingleNode('/server/version')
        $clientRegistrationIdNode = $xml.SelectSingleNode('/server/ClientRegistrationId')
        $webApiPortNode = $xml.SelectSingleNode('/server/WebApiConfig/Port')
        $authServerAddressNode = $xml.SelectSingleNode('/server/WebApiConfig/AuthorizationServerUri')


        $serviceProperties = 'Name', 'PathName', 'StartName', 'ProcessId', 'StartMode', 'State', 'Status'
        $serviceInfo = Get-CimInstance -ClassName 'Win32_Service' -Property $serviceProperties -Filter "name = 'Milestone XProtect Management Server'"

        $config = @{
            Version = if ($null -ne $versionNode) { [version]::Parse($versionNode.InnerText) } else { [version]::new(0, 0) }
            ClientRegistrationId = if ($null -ne $clientRegistrationIdNode) { [guid]$clientRegistrationIdNode.InnerText } else { [guid]::Empty }
            WebApiPort = if ($null -ne $webApiPortNode) { [int]$webApiPortNode.InnerText } else { 0 }
            AuthServerAddress = if ($null -ne $authServerAddressNode) { [uri]$authServerAddressNode.InnerText } else { $null }
            ServerCertHash = $null
            InstallationPath = $serviceInfo.PathName.Trim('"')
            ServiceInfo = $serviceInfo
        }

        $netshResult = Get-ProcessOutput -FilePath 'netsh.exe' -ArgumentList "http show sslcert ipport=0.0.0.0:$($config.WebApiPort)"
        if ($netshResult.StandardOutput -match 'Certificate Hash\s+:\s+(\w+)\s+') {
            $config.ServerCertHash = $Matches.1
        }

        Write-Output ([pscustomobject]$config)
    }
}
