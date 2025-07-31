Context 'AlarmDefinitions' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        $script:ExistingAlarms = Get-VmsAlarmDefinition
        $ms = Get-VmsManagementServer
        $ms.TimeProfileFolder.TimeProfiles | Where-Object Name -Match '^Test Time Profile' | ForEach-Object {
            $null = $ms.TimeProfileFolder.RemoveTimeProfile($_.Path)
        }
        $ms.TimeProfileFolder.ClearChildrenCache()
        Get-UserDefinedEvent | Where-Object Name -Match 'abledBy UDE' | Remove-UserDefinedEvent

        $invokeInfo = (Get-VmsManagementServer).TimeProfileFolder.AddTimeProfile()
        $invokeInfo.Name = 'Test Time Profile'
        $invokeResult = $invokeInfo.ExecuteDefault()
        $script:TimeProfile = (Get-VmsManagementServer).TimeProfileFolder.TimeProfiles | Where-Object Path -EQ $invokeResult.Path
        $script:EnabledByUDE = Add-UserDefinedEvent -Name 'EnabledBy UDE'
        $script:DisabledByUDE = Add-UserDefinedEvent -Name 'DisabledBy UDE'
    }

    Describe 'New-VmsAlarmDefinition' {
        It '<name>' -ForEach @(
            @{
                Name   = 'Simple parameters'
                Params = @{
                    Name           = "New Alarm $([datetime]::now.Ticks)"
                    EventTypeGroup = 'Device Events'
                    EventType      = 'Motion Started Driver'
                    Source         = 'AllCameras'
                }
            },
            @{
                Name   = 'Explicit TimeProfile - Always'
                Params = @{
                    Name           = "New Alarm $([datetime]::now.Ticks)"
                    EventTypeGroup = 'Device Events'
                    EventType      = 'Motion Started Driver'
                    Source         = 'AllCameras'
                    TimeProfile    = 'Always'
                }
            },
            @{
                Name   = 'Explicit TimeProfile - User Defined'
                Params = @{
                    Name           = "New Alarm $([datetime]::now.Ticks)"
                    EventTypeGroup = 'Device Events'
                    EventType      = 'Motion Started Driver'
                    Source         = 'AllCameras'
                    TimeProfile    = 'Test Time Profile'
                }
            },
            @{
                Name   = 'EnabledBy User-defined Event'
                Params = @{
                    Name           = "New Alarm $([datetime]::now.Ticks)"
                    EventTypeGroup = 'Device Events'
                    EventType      = 'Motion Started Driver'
                    Source         = 'AllCameras'
                    EnabledBy      = 'EnabledBy UDE'
                    DisabledBy     = 'DisabledBy UDE'
                }
            }
        ) {
            $Params.Name = "$Name $([datetime]::now.Ticks)"
            if ($Params.EnabledBy) {
                $Params.EnabledBy = Get-UserDefinedEvent -Name $Params.EnabledBy
                $Params.DisabledBy = Get-UserDefinedEvent -Name $Params.DisabledBy
            }
            $def = New-VmsAlarmDefinition @Params
            $def | Should -BeOfType -ExpectedType ([VideoOS.Platform.ConfigurationItems.AlarmDefinition])
            $def.Name | Should -BeExactly $Params.Name
        }
    }

    Describe 'Set-VmsAlarmDefinition' {
        BeforeAll {
            $alarmParams = @{
                Name           = "Set-VmsAlarmDefinition $([datetime]::now.Ticks)"
                EventTypeGroup = 'Device Events'
                EventType      = 'Motion Started Driver'
                Source         = 'AllCameras'
                ErrorAction    = 'Stop'
            }
            $script:alarm = New-VmsAlarmDefinition @alarmParams

        }

        It 'Can change name' {
            $newName = "New Alarm Definition Name $([datetime]::now.Ticks)"
            $script:alarm | Set-VmsAlarmDefinition -Name $newName
            (Get-VmsManagementServer).AlarmDefinitionFolder.ClearChildrenCache()
            (Get-VmsAlarmDefinition -Name $newName) | Should -Not -BeNullOrEmpty
        }

        It 'Can change TimeProfile' {
            $script:alarm | Set-VmsAlarmDefinition -TimeProfile 'Test Time Profile' -ErrorAction Stop
            (Get-VmsManagementServer).AlarmDefinitionFolder.ClearChildrenCache()
            (Get-VmsAlarmDefinition -Name $script:alarm.Name).TimeProfile | Should -Be $script:TimeProfile.Path
        }
    }

    Describe 'Remove-VmsAlarmDefinition' {
        It 'Can remove alarm definitions' {
            (Get-VmsManagementServer).AlarmDefinitionFolder.ClearChildrenCache()
            $alarms = Get-VmsAlarmDefinition
            $alarms | Where-Object Path -NotIn $script:ExistingAlarms.Path | Remove-VmsAlarmDefinition -Confirm:$false
            (Get-VmsManagementServer).AlarmDefinitionFolder.ClearChildrenCache()
            $alarms.Count | Should -BeGreaterThan (Get-VmsAlarmDefinition).Count
        }
    }
}
