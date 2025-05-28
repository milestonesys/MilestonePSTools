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

function ConvertTo-Uri {
    <#
    .SYNOPSIS
    Accepts an IPv4 or IPv6 address and converts it to an http or https URI

    .DESCRIPTION
    Accepts an IPv4 or IPv6 address and converts it to an http or https URI. IPv6 addresses need to
    be wrapped in square brackets when used in a URI. This function is used to help normalize data
    into an expected URI format.

    .PARAMETER IPAddress
    Specifies an IPAddress object of either Internetwork or InternetworkV6.

    .PARAMETER UseHttps
    Specifies whether the resulting URI should use https as the scheme instead of http.

    .PARAMETER HttpPort
    Specifies an alternate port to override the default http/https ports.

    .EXAMPLE
    '192.168.1.1' | ConvertTo-Uri
    #>
    [CmdletBinding()]
    [OutputType([uri])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [IPAddress]
        $IPAddress,

        [Parameter()]
        [switch]
        $UseHttps,

        [Parameter()]
        [int]
        $HttpPort = 80
    )

    process {
        $builder = [uribuilder]::new()
        $builder.Scheme = if ($UseHttps) { 'https' } else { 'http' }
        $builder.Host = if ($IPAddress.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetworkV6) {
            "[$IPAddress]"
        }
        else {
            $IPAddress
        }
        $builder.Port = $HttpPort
        Write-Output $builder.Uri
    }
}

