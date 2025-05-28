#Requires -Modules @{ ModuleName = 'MilestonePSTools'; ModuleVersion = '23.2.3' }
using namespace MilestonePSTools

function Group-DevicesByModel {
    <#
    .SYNOPSIS
    Creates a device group for each hardware make and model for one or more device types.
    
    .DESCRIPTION
    Creates a device group for each hardware make and model for one or more device types including cameras, microphones,
    speakers, metadata, inputs, and outputs.

    Creates a base device group for cameras, microphones, speakers, metadata, inputs, and/or outputs, and within each
    base group, it creates a group for every selected device by make/model. For each model, a group is created with a
    name like 1-X where X is the number of devices in that group. If the number exceeds 400, it will create another
    group called 401-X, until all selected devices of that model have been added to a group.
    
    Groups larger than 400 should not be created as the Management Client will not be able to do bulk configurations on them.

    Having groups of devices by model is very useful for doing bulk configuration changes in the Management Client. Note
    that in some instances, devices report their models as a series of and not a specific model. In cases like this,
    bulk configuration will likely not work as the cameras in the series might support different resolutions and/or
    frame rates.
    
    .PARAMETER BaseGroupPath
    Specifies the device group under which subgroups should be created by model. For example, "/__ADMIN__/Models".
    
    .PARAMETER MaxGroupSize
    Specifies the maximum number of devices to add to a single device group. The default value is 400 which is also the
    maximum number of devices the Management Client will allow bulk configuration operations on.
    
    .PARAMETER EnableFilter
    Specifies whether the device groups should include enabled, disabled, or all devices. The default behavior is to
    add only enabled devices to groups.
    
    .PARAMETER Hardware
    If omitted, all hardware on all recording servers on the VMS will be grouped by model under the specified base device
    group path. By providing a list of hardware, you can selectively group cameras by model based on the recording server
    for example.
    
    .PARAMETER DeviceType
    Specifies one or more device types to group by hardware model. The default behavior is to create camera groups, but
    you may specify any combination or all device types.
    
    .EXAMPLE
    Group-DevicesByModel -BaseGroupPath "/GroupedByModel"

    Create a camera group named "GroupedByModel" with all enabled cameras divided into groups by hardware model.

    .EXAMPLE
    Group-DevicesByModel -BaseGroupPath /zzADMIN__/Models -MaxGroupSize 200 -DeviceType Camera, Microphone, Metadata

    Creates a top-level group called "zzADMIN__" which will typically be listed at the bottom of the device group list, and
    a "Models" subgroup. Cameras, microphones, and metadata devices are then grouped by model under the Models subgroup
    with a maximum group size of 200 devices.

    .EXAMPLE
    Get-VmsRecordingServer | Foreach-Object {
        $hw = $_ | Get-VmsHardware
        Group-DevicesByModel -BaseGroupPath "/Recorders/$($_.Name)" -DeviceType Camera, Microphone, Speaker, InputEvent, Output, Metadata
    }

    Create a device group named after each recording server for all device types, and for each recording server, create
    device groups by model for the hardware on that recording server.
    #>
    [CmdletBinding()]
    [RequiresVmsConnection()]
    param (
        [Parameter(Position = 0, ValueFromPipelineByPropertyName, Mandatory)]
        [string]
        $BaseGroupPath,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName)]
        [ValidateRange(1, 400)]
        [int]
        $MaxGroupSize = 400,

        [Parameter(ValueFromPipelineByPropertyName)]
        [VideoOS.ConfigurationApi.ClientService.EnableFilter]
        $EnableFilter = [VideoOS.ConfigurationApi.ClientService.EnableFilter]::Enabled,

        [Parameter()]
        [VideoOS.Platform.ConfigurationItems.Hardware[]]
        $Hardware,

        [Parameter()]
        [ValidateSet('Camera', 'Microphone', 'Speaker', 'Metadata', 'InputEvent', 'Output')]
        [string[]]
        $DeviceType = 'Camera'
    )

    begin {
        Assert-VmsRequirementsMet
        $BaseGroupPath = '/{0}' -f $BaseGroupPath.Trim('/')
        $DeviceType = $DeviceType | Select-Object -Unique
    }

    process {
        $parentProgress = @{
            Activity        = 'Creating device groups by model'
            Status          = 'Discovering hardware models'
            Id              = Get-Random
            PercentComplete = 0
        }
        try {
            Write-Progress @parentProgress
            
            Write-Verbose "Removing camera group '$BaseGroupPath' if present"
            Clear-VmsCache
            $DeviceType | ForEach-Object {
                Get-VmsDeviceGroup -Path "/$($_)GroupFolder$BaseGroupPath" -ErrorAction SilentlyContinue | Remove-VmsDeviceGroup -Recurse -Confirm:$false -ErrorAction Stop
            }
            
            Write-Verbose "Discovering $($EnableFilter.ToString().ToLower()) devices"
            $ms = [VideoOS.Platform.ConfigurationItems.ManagementServer]::new((Get-VmsSite).FQID)
            $filters = (@('RecordingServer', 'Hardware') + $DeviceType) | ForEach-Object {
                [VideoOS.ConfigurationApi.ClientService.ItemFilter]::new($_, $null, $EnableFilter)
            }
            $ms.FillChildren($filters.ItemType, $filters)

            $parentProgress.Status = 'Grouping and sorting devices'
            Write-Progress @parentProgress

            Write-Verbose 'Sorting devices by model'
            $filterScript = {
                if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Hardware')) {
                    $_.Id -in $Hardware.Id
                } else {
                    $true
                }
            }
            $modelGroups = $ms.RecordingServerFolder.RecordingServers.HardwareFolder.Hardwares | Where-Object $filterScript | Group-Object Model | Sort-Object Name
            $totalDevices = ($DeviceType | ForEach-Object { ($modelGroups.Group."$($_)Folder"."$($_)s").Count } | Measure-Object -Sum).Sum
            $devicesProcessed = 0
            foreach ($type in $DeviceType) {
                try {
                    $childProgress = @{
                        Activity        = "Populating $type groups"
                        Id              = Get-Random
                        ParentId        = $parentProgress.Id
                        PercentComplete = 0
                    }
        
                    $parentProgress.Status = 'Processing'
                    Write-Progress @parentProgress
        
                    foreach ($group in $modelGroups) {
                        $modelName = $group.Name
                        $safeModelName = $modelName.Replace('/', '`/')
        
                        $devices = $group.Group."$($type)Folder"."$($type)s" | Sort-Object Name
                        $totalForModel = $devices.Count
                        
                        $groupNumber = $positionInGroup = 1
                        $group = $null
                        
                        $childProgress.Status = "Current: $BaseGroupPath/$modelName"
                        $parentProgress.PercentComplete = $devicesProcessed / $totalDevices * 100
                        Write-Progress @parentProgress
        
                        Write-Verbose "Creating groups for $totalForModel $type devices of model '$modelName'"
                        for ($i = 0; $i -lt $totalForModel; $i++) {
                            $childProgress.PercentComplete = $i / $totalForModel * 100
                            Write-Progress @childProgress
                            if ($null -eq $group) {
                                $first = $groupNumber * $MaxGroupSize - ($MaxGroupSize - 1)
                                $last = $groupNumber * $MaxGroupSize
                                if ($totalForModel - ($i + 1) -lt $MaxGroupSize) {
                                    $last = $totalForModel
                                }
                                $groupName = '{0}-{1}' -f $first, $last
                                $groupPath = "/$($type)GroupFolder$BaseGroupPath/$safeModelName/$groupName"
                                Write-Verbose "Creating group $groupPath"
                                $group = New-VmsDeviceGroup -Path $groupPath
                            }
        
                            Add-VmsDeviceGroupMember -Group $group -Device $devices[$i]
        
                            $devicesProcessed++
                            $positionInGroup++
                            if ($positionInGroup -gt $MaxGroupSize) {
                                $group = $null
                                $positionInGroup = 1
                                $groupNumber++
                            }
                        }
                    }
                } finally {
                    $childProgress.Completed = $true
                    Write-Progress @childProgress
                }
            }
        } finally {
            $parentProgress.Completed = $true
            Write-Progress @parentProgress
        }
    }
}
