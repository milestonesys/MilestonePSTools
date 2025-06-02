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

function Set-VmsAlarmDefinition {
    [CmdletBinding(SupportsShouldProcess)]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [ArgumentCompleter([MipItemNameCompleter[AlarmDefinition]])]
        [MipItemTransformation([AlarmDefinition])]
        [AlarmDefinition[]]
        $AlarmDefinition,

        [Parameter()]
        [string]
        $Name,

        # Specifies one or more devices in the form of a Configuration Item
        # Path like "Camera[e6d71e26-4c27-447d-b719-7db14fef8cd7]".
        [Parameter()]
        [Alias('Path')]
        [string[]]
        $Source,

        # Specifies the related cameras in the form of a comma-separated list of Configuration Item paths.
        [Parameter()]
        [string[]]
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

        [Parameter(ParameterSetName="SmartMap")]
        [switch]
        $SmartMap,

        [Parameter(ParameterSetName="RelatedMap")]
        [string]
        $RelatedMap,

        [Parameter()]
        [string]
        $Owner,

        # UDE's or outputs?
        [Parameter()]
        [string[]]
        $EventsToTrigger,

        [Parameter()]
        [switch]
        $PassThru
    )
    
    begin {
        Assert-VmsRequirementsMet
    }

    process {
        foreach ($def in $AlarmDefinition) {
            $alarmName = $def.Name
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Name')) {
                $def.Name = $Name
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Instructions')) {
                $def.Description = $Instructions
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('AssignableToAdmins')) {
                $def.AssignableToAdmins = $AssignableToAdmins.ToBool()
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('EventsToTrigger')) {
                $def.TriggerEventlist = $EventsToTrigger -join ','
            }
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Owner')) {
                $def.Owner = $Owner
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

            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('EventTriggered')) {
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
            }

            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('SmartMap')) {
                $def.MapType = 2
                $def.RelatedMap = ''
            }

            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Timeout')) {
                $def.ManagementTimeoutTime = $Timeout.ToString()
            }
            
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('TimeoutAction')) {
                $def.ManagementTimeoutEventList = $TimeoutAction -join ','
            }
            
            if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Source')) {
                $sourceHelpers = @{
                    'AllCameras'     = '/CameraFolder'
                    'AllMicrophones' = '/MicrophoneFolder'
                    'AllSpeakers'    = '/SpeakerFolder'
                    'AllInputs'      = '/InputEventFolder'
                    'AllOutputs'     = '/OutputFolder'
                    'AllEvents'      = '/UserDefinedEventFolder'
                    'AllServers'     = '/'
                }
    
                $def.SourceList = ($Source | ForEach-Object {
                        if ($sourceHelpers.ContainsKey($_)) { $sourceHelpers[$_] } else { $_ }
                    }) -join ','
            }
            

            if ($RelatedCameras.Count -gt 0) {
                $def.RelatedCameraList = $RelatedCameras -join ','
            }
    
            try {
                if ($PSCmdlet.ShouldProcess($alarmName, 'Set Alarm Definition')) {
                    $null = $def.Save()
                    if ($PassThru) {
                        $def
                    }
                }
            } catch [VideoOS.Platform.Proxy.ConfigApi.ValidateResultException] {
                HandleValidateResultException -ErrorRecord $_ -TargetObject $def -ItemName $def.Name
            } catch {
                Write-Error "Set-VmsAlarmDefinition failed: $($_.Exception.Message)" -TargetObject $def
                return
            }
        }
    }

    end {
        (Get-VmsManagementServer).AlarmDefinitionFolder.ClearChildrenCache()
    }
}

Register-ArgumentCompleter -CommandName Set-VmsAlarmDefinition -ParameterName EventTypeGroup -ScriptBlock $eventTypeGroupArgCompleter
Register-ArgumentCompleter -CommandName Set-VmsAlarmDefinition -ParameterName EventType -ScriptBlock $eventTypeArgCompleter
Register-ArgumentCompleter -CommandName Set-VmsAlarmDefinition -ParameterName TimeProfile -ScriptBlock $timeProfileArgCompleter
Register-ArgumentCompleter -CommandName Set-VmsAlarmDefinition -ParameterName Priority -ScriptBlock $priorityArgCompleter
Register-ArgumentCompleter -CommandName Set-VmsAlarmDefinition -ParameterName Category -ScriptBlock $categoryArgCompleter
Register-ArgumentCompleter -CommandName Set-VmsAlarmDefinition -ParameterName RelatedMap -ScriptBlock $relatedMapArgCompleter
Register-ArgumentCompleter -CommandName Set-VmsAlarmDefinition -ParameterName Source -ScriptBlock $sourceArgCompleter
