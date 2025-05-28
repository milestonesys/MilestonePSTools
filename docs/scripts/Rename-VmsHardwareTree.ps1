function Rename-VmsHardwareTree {
    <#
    .SYNOPSIS
    Renames hardware and all child devices using the default pattern.
    
    .DESCRIPTION
    This function renames the provided hardware(s) and all child devices. If a
    value is provided for BaseName, the hardware will be renamed. The BaseName
    can contain case-insensitive placeholders for any property available on a
    Hardware object.
    
    For example, the default naming pattern applied when adding hardware in
    XProtect can be represented using "<model> (<ipaddress>)". Note that the
    Hardware object does not have an "IpAddress" property, but one will be
    added based on the host portion of the http(s) url in the Address property.

    If no value for BaseName is provided, the hardware will not be renamed and
    the existing hardware names will be used for BaseName.

    Child devices of all types (camera, microphone, speaker, metadata, input,
    and output), will be renamed following the pattern
    "<BaseName> - <DeviceType> <Channel>".
    
    .PARAMETER Hardware
    Specifies one or more Hardware. Use the Get-VmsHardware command to get
    hardware.
    
    .PARAMETER BaseName
    Specifies an optional new hardware name. If no value is provided, the
    existing hardware name will be used for BaseName. Child devices will be
    renamed based on the pattern "<BaseName> - <DeviceType> <Channel>".
    
    .EXAMPLE
    Get-VmsHardware | Rename-VmsHardwareTree

    Rename all camera, microphone, speaker, metadata, input, and output devices
    to match the current name of the parent hardware with " - <deviceType> <channel>"
    appended to the end. For example, if a hardware name is "Garage Entrance (192.168.1.101)",
    the first camera channel will be renamed to "Garage Entrance (192.168.1.101) - Camera 1"
    and the third output (if available) would be named "Garage Entrance (192.168.1.101) - Output 3".
    
    .EXAMPLE
    Get-VmsHardware | Rename-VmsHardwareTree -BaseName '<model> (<ipaddress>)'

    Rename all hardware and child devices based on the default XProtect hardware and
    device naming conventions.
    
    .EXAMPLE
    $recorders = Get-VmsRecordingServer | Out-GridView -OutputMode Multiple
    $recorders | Get-VmsHardware | Rename-VmsHardwareTree -BaseName '<model> (<ipaddress>)'

    Rename all hardware on the selected recording server(s) based on the
    default XProtect naming conventions.

    .EXAMPLE
    $recorders = Get-VmsRecordingServer | Out-GridView -OutputMode Multiple
    $recorders | ForEach-Object {
        $rec = $_
        $rec | Get-VmsHardware | Rename-VmsHardwareTree -BaseName "$($rec.Name) <model> (<ipaddress>)"
    }

    Rename all hardware on the selected recording server(s) based on the
    default XProtect naming conventions, but prefix all names with the display
    name of the parent recording server.

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [VideoOS.Platform.ConfigurationItems.Hardware[]]
        $Hardware,

        [Parameter()]
        [string]
        $BaseName
    )
    
    process {
        foreach ($hw in $Hardware) {
            $newName = $hw.Name
            if (-not [string]::IsNullOrEmpty($BaseName)) {
                $hw | Add-Member -MemberType NoteProperty -Name IpAddress -Value ([uri]$hw.Address).Host
                $regex = [regex]::new('<(?<property>\w+)>')
                $newName = $BaseName
                foreach ($m in $regex.Matches($BaseName)) {
                    $propertyName = $m.Groups['property'].Value
                    if ($null -eq $hw.$propertyName) {
                        Write-Warning "Ignoring unrecognized placeholder '$($m.Groups[0].Value)'"
                        continue
                    }
                    $newName = $newName.Replace($m.Groups[0].Value, $hw.$propertyName)
                }
            }

            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('BaseName')) {
                $hw | Set-VmsHardware -Name $newName
            }
            
            $passthruProperties = @(
                @{n='Hardware';e={$hw.Name}},
                'Name'
            )
            $deviceTypes = 'Camera', 'Microphone', 'Speaker', 'Metadata', 'Input', 'Output'
            foreach ($device in $hw | Get-VmsDevice -Type $deviceTypes -EnableFilter All) {
                $deviceType = ($device.Path -split '\[')[0]
                $device | Set-VmsDevice -Name "$newName - $deviceType $($device.Channel + 1)" -PassThru | Select-Object $passthruProperties
            }
        }
    }
}
