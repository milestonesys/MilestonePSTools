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

class CidrInfo {
    [string] $Cidr
    [IPAddress] $Address
    [int] $Mask

    [IPAddress] $Start
    [IPAddress] $End
    [IPAddress] $SubnetMask
    [IPAddress] $HostMask

    [int] $TotalAddressCount
    [int] $HostAddressCount

    CidrInfo([string] $Cidr) {
        [System.Net.IPAddress]$this.Address, [int]$this.Mask = $Cidr -split '/'
        if ($this.Address.AddressFamily -notin @([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.AddressFamily]::InterNetworkV6)) {
            throw "CidrInfo is not compatible with AddressFamily $($this.Address.AddressFamily). Expected InterNetwork or InterNetworkV6."
        }
        $min, $max = if ($this.Address.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork) { 0, 32 } else { 0, 128 }
        if ($this.Mask -lt $min -or $this.Mask -gt $max) {
            throw "CIDR mask value out of range. Expected a value between $min and $max for AddressFamily $($this.Address.AddressFamily)"
        }
        $hostMaskLength = $max - $this.Mask
        $this.Cidr = $Cidr
        $this.TotalAddressCount = [math]::pow(2, $hostMaskLength)
        # RFC 3021 support is assumed. When the range supports only two hosts, RFC 3021 defines it usable for point-to-point communications but not all systems support this.
        $this.HostAddressCount = if ($hostMaskLength -eq 0) { 1 } elseif ($hostMaskLength -eq 1) { 2 } else { $this.TotalAddressCount - 2 }

        $addressBytes = $this.Address.GetAddressBytes()
        $netMaskBytes = [byte[]]::new($addressBytes.Count)
        $hostMaskBytes = [byte[]]::new($addressBytes.Count)
        $bitCounter = 0
        for ($octet = 0; $octet -lt $addressBytes.Count; $octet++) {
            for ($bit = 0; $bit -lt 8; $bit++) {
                $bitCounter += 1
                $bitValue = 0
                if ($bitCounter -le $this.Mask) {
                    $bitValue = 1
                }
                $netMaskBytes[$octet] = $netMaskBytes[$octet] -bor ( $bitValue -shl ( 7 - $bit ) )
                $hostMaskBytes[$octet] = $netMaskBytes[$octet] -bxor 255
            }
        }
        $this.SubnetMask = [ipaddress]::new($netMaskBytes)
        $this.HostMask = [IPAddress]::new($hostMaskBytes)

        $startBytes = [byte[]]::new($addressBytes.Count)
        $endBytes = [byte[]]::new($addressBytes.Count)
        for ($octet = 0; $octet -lt $addressBytes.Count; $octet++) {
            $startBytes[$octet] = $addressBytes[$octet] -band $netMaskBytes[$octet]
            $endBytes[$octet] = $addressBytes[$octet] -bor $hostMaskBytes[$octet]
        }
        $this.Start = [IPAddress]::new($startBytes)
        $this.End = [IPAddress]::new($endBytes)
    }
}

function Expand-IPRange {
    <#
    .SYNOPSIS
    Expands a start and end IP address or a CIDR notation into an array of IP addresses within the given range.

    .DESCRIPTION
    Accepts start and end IP addresses in the form of IPv4 or IPv6 addresses, and returns each IP
    address falling within the range including the Start and End values.

    The Start and End IP addresses must be in the same address family (IPv4 or IPv6) and if the
    addresses are IPv6, they must have the same scope ID.

    .PARAMETER Start
    Specifies the first IP address in the range to be expanded.

    .PARAMETER End
    Specifies the last IP address in the range to be expanded. Must be greater than or equal to Start.

    .PARAMETER Cidr
    Specifies an IP address range in CIDR notation. Example: 192.168.0.0/23 represents 192.168.0.0-192.168.1.255.

    .PARAMETER AsString
    Specifies that each IP address in the range should be returned as a string instead of an [IPAddress] object.

    .EXAMPLE
    PS C:\> Expand-IPRange -Start 192.168.1.1 -End 192.168.2.255
    Returns 511 IPv4 IPAddress objects.

    .EXAMPLE
    PS C:\> Expand-IPRange -Start fe80::5566:e22e:3f34:5a0f -End fe80::5566:e22e:3f34:5a16
    Returns 8 IPv6 IPAddress objects.

    .EXAMPLE
    PS C:\> Expand-IPRange -Start 10.1.1.100 -End 10.1.10.50 -AsString
    Returns 2255 IPv4 addresses as strings.

    .EXAMPLE
    PS C:\> Expand-IPRange -Cidr 172.16.16.0/23
    Returns IPv4 IPAddress objects from 172.16.16.0 to 172.16.17.255.
    #>
    [CmdletBinding(DefaultParameterSetName = 'FromRange')]
    [OutputType([System.Net.IPAddress], [string])]
    param(
        [Parameter(Mandatory, ParameterSetName = 'FromRange')]
        [ValidateScript({
            if ($_.AddressFamily -in @([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.AddressFamily]::InterNetworkV6)) {
                return $true
            }
            throw "Start IPAddress is from AddressFamily '$($_.AddressFamily)'. Expected InterNetwork or InterNetworkV6."
        })]
        [System.Net.IPAddress]
        $Start,

        [Parameter(Mandatory, ParameterSetName = 'FromRange')]
        [ValidateScript({
            if ($_.AddressFamily -in @([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.AddressFamily]::InterNetworkV6)) {
                return $true
            }
            throw "Start IPAddress is from AddressFamily '$($_.AddressFamily)'. Expected InterNetwork or InterNetworkV6."
        })]
        [System.Net.IPAddress]
        $End,

        [Parameter(Mandatory, ParameterSetName = 'FromCidr')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Cidr,

        [Parameter()]
        [switch]
        $AsString
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'FromCidr') {
            $cidrInfo = [CidrInfo]$Cidr
            $Start = $cidrInfo.Start
            $End = $cidrInfo.End
        }

        if (-not $Start.AddressFamily.Equals($End.AddressFamily)) {
            throw 'Expand-IPRange received Start and End addresses from different IP address families (IPv4 and IPv6). Both addresses must be of the same IP address family.'
        }

        if ($Start.ScopeId -ne $End.ScopeId) {
            throw 'Expand-IPRange received IPv6 Start and End addresses with different ScopeID values. The ScopeID values must be identical.'
        }

        # Assert that the End IP is greater than or equal to the Start IP.
        $startBytes = $Start.GetAddressBytes()
        $endBytes = $End.GetAddressBytes()
        for ($i = 0; $i -lt $startBytes.Length; $i++) {
            if ($endBytes[$i] -lt $startBytes[$i]) {
                throw 'Expand-IPRange must receive an End IPAddress which is greater than or equal to the Start IPAddress'
            }
            if ($endBytes[$i] -gt $startBytes[$i]) {
                # We can break early if a higher-order byte from the End address is greater than the matching byte of the Start address
                break
            }
        }

        $current = $Start
        while ($true) {
            if ($AsString) {
                Write-Output $current.ToString()
            }
            else {
                Write-Output $current
            }

            if ($current.Equals($End)) {
                break
            }

            $bytes = $current.GetAddressBytes()
            for ($i = $bytes.Length - 1; $i -ge 0; $i--) {
                if ($bytes[$i] -lt 255) {
                    $bytes[$i] += 1
                    break
                }
                $bytes[$i] = 0
            }
            if ($null -ne $current.ScopeId) {
                $current = [System.Net.IPAddress]::new($bytes, $current.ScopeId)
            }
            else {
                $current = [System.Net.IPAddress]::new($bytes)
            }
        }
    }
}

