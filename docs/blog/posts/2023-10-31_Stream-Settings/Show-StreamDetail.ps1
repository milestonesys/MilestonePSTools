function Show-StreamDetail {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [object]
        $Stream
    )

    begin {
        $driverSettings = @{}
    }
    
    process {
        $path = 'DeviceDriverSettings[{0}]' -f $Stream.Camera.Id
        if (-not $driverSettings.ContainsKey($path)) {
            $driverSettings[$path] = Get-ConfigurationItem -Path $path
        }
        $item = $driverSettings[$path]
        $streamSettings = ($item.Children | Where-Object DisplayName -eq $Stream.Name).Properties
        $keys = $Stream.Settings.Keys | Sort-Object
        foreach ($key in $keys) {
            $value = $Stream.Settings[$key]
            $info = $Stream.ValueTypeInfo[$key] | Where-Object {
                ($_.Name -eq $value -or $_.Value -eq $value) -and $_.Name -notmatch '^(Min|Max|Step)Value$'
            }
            $detailedSetting = $streamSettings | Where-Object Key -Match ('\b{0}\b' -f [regex]::Escape($key))
            [pscustomobject]@{
                DisplayName  = $detailedSetting.DisplayName
                Key          = $key
                DisplayValue = if ($info) { $info.Name } else { $value }
                Value        = if ($info) { $info.Value } else { $value }
                ValueType    = $detailedSetting.ValueType
                MinValue     = ($Stream.ValueTypeInfo[$key] | Where-Object Name -eq 'MinValue').Value
                MaxValue     = ($Stream.ValueTypeInfo[$key] | Where-Object Name -eq 'MaxValue').Value
                StepValue    = ($Stream.ValueTypeInfo[$key] | Where-Object Name -eq 'StepValue').Value
                EnumOptions  = if ($detailedSetting.ValueType -eq 'Enum') { ($detailedSetting.ValueTypeInfos | Where-Object { $_.Name -notmatch '^(Min|Max|Step)Value$' }).Value -join ', '  } else { $null }
            }
        }
    }
}


