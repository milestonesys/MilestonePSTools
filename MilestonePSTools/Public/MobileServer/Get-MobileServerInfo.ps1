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

function Get-MobileServerInfo {
    [CmdletBinding()]
    [RequiresVmsConnection($false)]
    param ()

    begin {
        Assert-VmsRequirementsMet
    }

    process {
        try {
            $mobServerPath = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\WOW6432Node\Milestone\XProtect Mobile Server' -Name INSTALLATIONFOLDER
            [Xml]$doc = Get-Content "$mobServerPath.config" -ErrorAction Stop

            $xpath = "/configuration/ManagementServer/Address/add[@key='Ip']"
            $msIp = $doc.SelectSingleNode($xpath).Attributes['value'].Value
            $xpath = "/configuration/ManagementServer/Address/add[@key='Port']"
            $msPort = $doc.SelectSingleNode($xpath).Attributes['value'].Value

            $xpath = "/configuration/HttpMetaChannel/Address/add[@key='Port']"
            $httpPort = [int]::Parse($doc.SelectSingleNode($xpath).Attributes['value'].Value)
            $xpath = "/configuration/HttpMetaChannel/Address/add[@key='Ip']"
            $httpIp = $doc.SelectSingleNode($xpath).Attributes['value'].Value
            if ($httpIp -eq '+') { $httpIp = '0.0.0.0'}

            $xpath = "/configuration/HttpSecureMetaChannel/Address/add[@key='Port']"
            $httpsPort = [int]::Parse($doc.SelectSingleNode($xpath).Attributes['value'].Value)
            $xpath = "/configuration/HttpSecureMetaChannel/Address/add[@key='Ip']"
            $httpsIp = $doc.SelectSingleNode($xpath).Attributes['value'].Value
            if ($httpsIp -eq '+') { $httpsIp = '0.0.0.0'}
            try {
                $hash = Get-HttpSslCertThumbprint -IPPort "$($httpsIp):$($httpsPort)" -ErrorAction Stop
            } catch {
                $hash = $null
            }
            $info = [PSCustomObject]@{
                Version = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($mobServerPath).FileVersion;
                ExePath = $mobServerPath;
                ConfigPath = "$mobServerPath.config";
                ManagementServerIp = $msIp;
                ManagementServerPort = $msPort;
                HttpIp = $httpIp;
                HttpPort = $httpPort;
                HttpsIp = $httpsIp;
                HttpsPort = $httpsPort;
                CertHash = $hash
            }
            $info
        } catch {
            Write-Error $_
        }
    }
}

