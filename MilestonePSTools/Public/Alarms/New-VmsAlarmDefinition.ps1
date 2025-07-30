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

function New-VmsAlarmDefinition {
    [CmdletBinding()]
    [MilestonePSTools.RequiresVmsConnection()]
    [OutputType([VideoOS.Platform.ConfigurationItems.AlarmDefinition])]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [string]
        $EventTypeGroup,

        [Parameter(Mandatory)]
        [string]
        $EventType,

        # Specifies one or more devices in the form of a Configuration Item
        # Path like "Camera[e6d71e26-4c27-447d-b719-7db14fef8cd7]".
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Path')]
        [string[]]
        $Source,

        [Parameter()]
        [VideoOS.Platform.ConfigurationItems.Camera[]]
        $RelatedCameras,

        [Parameter()]
        [string]
        $TimeProfile,

        # UDEs and Inputs
        [Parameter()]
        [string[]]
        $EnabledBy,
        
        # UDEs and Inputs
        [Parameter()]
        [string[]]
        $DisabledBy,

        [Parameter()]
        [string]
        $Instructions,

        [Parameter()]
        [string]
        $Priority,

        [Parameter()]
        [string]
        $Category,

        [Parameter()]
        [switch]
        $AssignableToAdmins,

        [Parameter()]
        [timespan]
        $Timeout = [timespan]::FromMinutes(1),

        [Parameter()]
        [string[]]
        $TimeoutAction,

        # Deprecated: SmartMap is the default.
        [Parameter()]
        [switch]
        $SmartMap,

        [Parameter()]
        [string]
        $RelatedMap,

        [Parameter()]
        [string]
        $Owner,

        # UDE's or outputs?
        [Parameter()]
        [string[]]
        $EventsToTrigger
    )
    
    begin {
        Assert-VmsRequirementsMet
        $sources = [system.collections.generic.list[string]]::new()
    }
    
    process {
        foreach ($path in $Source) {
            $sources.Add($path)
        }
    }

    end {
        $def = (Get-VmsManagementServer).AlarmDefinitionFolder.AddAlarmDefinition()
        $def.Name = $Name
        $def.Description = $Instructions
        $def.AssignableToAdmins = $AssignableToAdmins.ToBool()
        $def.TriggerEventlist = $EventsToTrigger -join ','
        $def.Owner = $Owner

        $eventTypeGroupId = [guid]::Empty
        if (![guid]::TryParse($EventTypeGroup, [ref]$eventTypeGroupId)) {
            $groupName = $def.EventTypeGroupValues.Keys | Where-Object { $_ -eq $EventTypeGroup }
            if ($null -eq $groupName) {
                Write-Error "EventTypeGroup '$EventTypeGroup' is not a valid EventTypeGroup name, or GUID."
                return
            }
            $eventTypeGroupid = $def.EventTypeGroupValues[$groupName]
        }
        $def.EventTypeGroup = $eventTypeGroupId
        
        $eventTypeId = [guid]::Empty
        if (![guid]::TryParse($EventType, [ref]$eventTypeId)) {
            $null = $def.ValidateItem()
            $eventName = $def.EventTypeValues.Keys | Where-Object { $_ -eq $EventType }
            if ($null -eq $eventName) {
                Write-Error "EventType '$EventType' is not a valid event name, or GUID. For a list of system events, try running (Get-VmsManagementServer).EventTypeGroupFolder.EventTypeGroups.EventTypeFolder.EventTypes | Select Name, DisplayName, Id"
                return
            }
            $eventTypeId = $def.EventTypeValues[$eventName]
        }
        $def.EventType = $eventTypeId

        $boundParameters = $PSCmdlet.MyInvocation.BoundParameters
        if (($boundParameters.ContainsKey('EnabledBy') -or $boundParameters.ContainsKey('DisabledBy') -and $boundParameters.ContainsKey('TimeProfile'))) {
            Write-Error 'Rules for when an alarm definition is enabled may either be based on a time profile, or a specified enable/disable event, but not both.'
            return
        }

        # TODO: Use switch on parametersetname to determine enablerule
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('TimeProfile')) {
            $timeProfiles = @{
                'Always' = 'TimeProfile[00000000-0000-0000-0000-000000000000]'
            }
            (Get-VmsManagementServer).TimeProfileFolder.TimeProfiles | ForEach-Object {
                if ($null -eq $_) { return }
                $timeProfiles[$_.Name] = $_.Path
            }

            if (!$timeProfiles.ContainsKey($TimeProfile)) {
                Write-Error "No TimeProfile found matching '$TimeProfile'"
                return
            }
            $def.TimeProfile = $timeProfiles[$TimeProfile]
            $def.EnableRule = 1
        }

        if ($PSCmdlet.ParameterSetName -eq 'EventTriggered') {
            $def.EnableEventList = $EnabledBy -join ','
            $def.DisableEventList = $DisabledBy -join ','
            $def.EnableRule = 2
        }

        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Priority')) {
            if (!$def.PriorityValues.ContainsKey($Priority)) {
                Write-Error "No alarm priority found with the name '$Priority'. Check your Alarm Data Settings in Management Client."
                return
            }
            $def.Priority = $def.PriorityValues[$Priority]
        }
        
        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Category')) {
            if (!$def.CategoryValues.ContainsKey($Category)) {
                Write-Error "No alarm category found with the name '$Category'. Check your Alarm Data Settings in Management Client."
                return
            }
            $def.Category = $def.CategoryValues[$Category]
        }

        if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('RelatedMap')) {
            if (!$def.RelatedMapValues.ContainsKey($RelatedMap)) {
                Write-Error "No related map found with the name '$RelatedMap'. Check the map name and try again."
                return
            }
            $def.MapType = 1
            $def.RelatedMap = $def.RelatedMapValues[$RelatedMap]
        } else {
            # Default to SmartMap
            $def.MapType = 2
            $def.RelatedMap = ''
        }

        $def.ManagementTimeoutTime = $Timeout.ToString()
        $def.ManagementTimeoutEventList = $TimeoutAction -join ','

        $sourceHelpers = @{
            'AllCameras'     = '/CameraFolder'
            'AllMicrophones' = '/MicrophoneFolder'
            'AllSpeakers'    = '/SpeakerFolder'
            'AllInputs'      = '/InputEventFolder'
            'AllOutputs'     = '/OutputFolder'
            'AllEvents'      = '/UserDefinedEventFolder'
            'AllServers'     = '/'
        }
        $def.SourceList = ($sources | ForEach-Object {
            if ($sourceHelpers.ContainsKey($_)) { $sourceHelpers[$_] } else { $_ }
        }) -join ','

        if ($RelatedCameras.Count -gt 0) {
            $def.RelatedCameraList = ($RelatedCameras | ForEach-Object Path) -join ','
        }
        
        try {
            $taskResult = $def.ExecuteDefault()
            if ($taskResult.State -ne 'Success') {
                Write-Error "New-VmsAlarmDefinition failed1: $($taskResult.ErrorText)" -TargetObject $def
                return
            }
        } catch {
            Write-Error "New-VmsAlarmDefinition failed2: $($_.Exception.Message)" -TargetObject $def
            return
        }
        
        
        (Get-VmsManagementServer).AlarmDefinitionFolder.ClearChildrenCache()
        (Get-VmsManagementServer).AlarmDefinitionFolder.AlarmDefinitions | Where-Object Path -EQ $taskResult.Path
    }
}


$eventTypeGroupArgCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $values = (Get-VmsManagementServer).AlarmDefinitionFolder.AddAlarmDefinition().EventTypeGroupValues.Keys | Sort-Object
    $values | Where-Object {
        $_ -like "$($wordToComplete.Trim('"', "'"))*"
    } | ForEach-Object {
        if ($_ -match '.*\s+.*') {
            "'$_'"
        } else {
            $_
        }
    }
}

$eventTypeArgCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $group = $fakeBoundParameters['EventTypeGroup']
    if ([string]::IsNullOrWhiteSpace($group)) {
        "'Tab completion unavailable until EventTypeGroup is set'"
        return
    }
    $info = (Get-VmsManagementServer).AlarmDefinitionFolder.AddAlarmDefinition()
    $groupNames = @{}
    $info.EventTypeGroupValues.Keys | ForEach-Object { $groupNames[$_] = $info.EventTypeGroupValues[$_] }
    if ($groupNames.ContainsKey($group)) {
        $group = $info.EventTypeGroupValues.Keys | Where-Object { $_ -eq $group }
        $info.EventTypeGroup = $info.EventTypeGroupValues[$group]
    } elseif ($groupNames.Values -contains $group) {
        $info.EventTypeGroup = $group
    } else {
        "'Invalid EventTypeGroup `"$group`"'"
        return
    }

    $null = $info.ValidateItem()
    $values = $info.EventTypeValues.Keys | Sort-Object
    if ($null -eq $values) {
        "'No events available for EventTypeGroup $group'"
    }
    
    $values | Where-Object {
        $_ -like "$($wordToComplete.Trim('"', "'"))*"
    } | ForEach-Object {
        if ($_ -match '.*\s+.*') {
            "'$_'"
        } else {
            $_
        }
    }
}

$timeProfileArgCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $values = [system.collections.generic.list[string]]::new()
    $values.Add('Always')
    (Get-VmsManagementServer).TimeProfileFolder.TimeProfiles | ForEach-Object {
        $values.Add($_.Name)
    } | Sort-Object
    $values | Where-Object {
        $_ -like "$($wordToComplete.Trim('"', "'"))*"
    } | ForEach-Object {
        if ($_ -match '.*\s+.*') {
            "'$_'"
        } else {
            $_
        }
    }
}

$priorityArgCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $values = (Get-VmsManagementServer).AlarmDefinitionFolder.AddAlarmDefinition().PriorityValues.Keys | Where-Object {
        ![string]::IsNullOrEmpty($_)
    } | Sort-Object
    $values | Where-Object {
        $_ -like "$($wordToComplete.Trim('"', "'"))*"
    } | ForEach-Object {
        if ($_ -match '.*\s+.*') {
            "'$_'"
        } else {
            $_
        }
    }
}

$categoryArgCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $values = (Get-VmsManagementServer).AlarmDefinitionFolder.AddAlarmDefinition().CategoryValues.Keys | Where-Object {
        ![string]::IsNullOrEmpty($_)
    } | Sort-Object
    $values | Where-Object {
        $_ -like "$($wordToComplete.Trim('"', "'"))*"
    } | ForEach-Object {
        if ($_ -match '.*\s+.*') {
            "'$_'"
        } else {
            $_
        }
    }
}

$relatedMapArgCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $values = (Get-VmsManagementServer).AlarmDefinitionFolder.AddAlarmDefinition().RelatedMapValues.Keys | Where-Object {
        ![string]::IsNullOrEmpty($_)
    } | Sort-Object
    $values | Where-Object {
        $_ -like "$($wordToComplete.Trim('"', "'"))*"
    } | ForEach-Object {
        if ($_ -match '.*\s+.*') {
            "'$_'"
        } else {
            $_
        }
    }
}

$sourceArgCompleter = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    $values = 'AllCameras', 'AllMicrophones', 'AllSpeakers', 'AllMetadatas', 'AllInputs', 'AllOutputs', 'AllServers', 'AllEvents'
    $values | Where-Object {
        $_ -like "$($wordToComplete.Trim('"', "'"))*"
    } | ForEach-Object {
        if ($_ -match '.*\s+.*') {
            "'$_'"
        } else {
            $_
        }
    }
}

Register-ArgumentCompleter -CommandName New-VmsAlarmDefinition -ParameterName EventTypeGroup -ScriptBlock $eventTypeGroupArgCompleter
Register-ArgumentCompleter -CommandName New-VmsAlarmDefinition -ParameterName EventType -ScriptBlock $eventTypeArgCompleter
Register-ArgumentCompleter -CommandName New-VmsAlarmDefinition -ParameterName TimeProfile -ScriptBlock $timeProfileArgCompleter
Register-ArgumentCompleter -CommandName New-VmsAlarmDefinition -ParameterName Priority -ScriptBlock $priorityArgCompleter
Register-ArgumentCompleter -CommandName New-VmsAlarmDefinition -ParameterName Category -ScriptBlock $categoryArgCompleter
Register-ArgumentCompleter -CommandName New-VmsAlarmDefinition -ParameterName RelatedMap -ScriptBlock $relatedMapArgCompleter
Register-ArgumentCompleter -CommandName New-VmsAlarmDefinition -ParameterName Source -ScriptBlock $sourceArgCompleter
