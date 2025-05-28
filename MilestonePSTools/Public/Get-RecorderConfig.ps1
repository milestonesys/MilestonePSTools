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

function Get-RecorderConfig {
    [CmdletBinding()]
    [RequiresVmsConnection($false)]
    param()

    begin {
        Assert-VmsRequirementsMet
        $configXml = Join-Path ([system.environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData)) 'milestone\xprotect recording server\recorderconfig.xml'
        if (-not (Test-Path $configXml)) {
            throw [io.filenotfoundexception]::new('Recording Server configuration file not found', $configXml)
        }
    }

    process {
        $xml = [xml](Get-Content -Path $configXml)
        
        $versionNode = $xml.SelectSingleNode('/recorderconfig/version')
        $recorderIdNode = $xml.SelectSingleNode('/recorderconfig/recorder/id')
        $clientRegistrationIdNode = $xml.SelectSingleNode('/recorderconfig/recorder/ClientRegistrationId')
        $webServerPortNode = $xml.SelectSingleNode('/recorderconfig/webserver/port')        
        $alertServerPortNode = $xml.SelectSingleNode('/recorderconfig/driverservices/alert/port')
        $serverAddressNode = $xml.SelectSingleNode('/recorderconfig/server/address')        
        $serverPortNode = $xml.SelectSingleNode('/recorderconfig/server/webapiport')        
        $localServerPortNode = $xml.SelectSingleNode('/recorderconfig/webapi/port')
        $authServerAddressNode = $xml.SelectSingleNode('/recorderconfig/server/authorizationserveraddress')

        $serviceProperties = 'Name', 'PathName', 'StartName', 'ProcessId', 'StartMode', 'State', 'Status'
        $serviceInfo = Get-CimInstance -ClassName 'Win32_Service' -Property $serviceProperties -Filter "name = 'Milestone XProtect Recording Server'"

        $config = @{
            Version = if ($null -ne $versionNode) { [version]::Parse($versionNode.InnerText) } else { [version]::new(0, 0) }
            RecorderId = if ($null -ne $recorderIdNode) { [guid]$recorderIdNode.InnerText } else { [guid]::Empty }
            ClientRegistrationId = if ($null -ne $clientRegistrationIdNode) { [guid]$clientRegistrationIdNode.InnerText } else { [guid]::Empty }
            WebServerPort = if ($null -ne $webServerPortNode) { [int]$webServerPortNode.InnerText } else { 0 }
            AlertServerPort = if ($null -ne $alertServerPortNode) { [int]$alertServerPortNode.InnerText } else { 0 }
            ServerAddress = $serverAddressNode.InnerText
            ServerPort = if ($null -ne $serverPortNode) { [int]$serverPortNode.InnerText } else { 0 }
            LocalServerPort = if ($null -ne $localServerPortNode) { [int]$localServerPortNode.InnerText } else { 0 }
            AuthServerAddress = if ($null -ne $authServerAddressNode) { [uri]$authServerAddressNode.InnerText } else { $null }
            ServerCertHash = $null
            InstallationPath = $serviceInfo.PathName.Trim('"')
            DevicePackPath = Get-ItemPropertyValue -Path HKLM:\SOFTWARE\WOW6432Node\VideoOS\DeviceDrivers -Name InstallPath
            ServiceInfo = $serviceInfo
        }

        $netshResult = Get-ProcessOutput -FilePath 'netsh.exe' -ArgumentList "http show sslcert ipport=0.0.0.0:$($config.LocalServerPort)"
        if ($netshResult.StandardOutput -match 'Certificate Hash\s+:\s+(\w+)\s+') {
            $config.ServerCertHash = $Matches.1
        }

        Write-Output ([pscustomobject]$config)
    }
}
