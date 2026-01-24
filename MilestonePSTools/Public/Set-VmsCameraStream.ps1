function Set-VmsCameraStream {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([MilestonePSTools.VmsCameraStreamConfig])]
    [RequiresVmsConnection()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'RemoveStream')]
        [switch]
        $Disabled,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'AddOrUpdateStream')]
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'RemoveStream')]
        [MilestonePSTools.VmsCameraStreamConfig[]]
        $Stream,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [string]
        $DisplayName,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [ValidateSet('Always', 'Never', 'WhenNeeded')]
        [string]
        $LiveMode,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [switch]
        $LiveDefault,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [switch]
        $Recorded,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [ValidateSet('Primary', 'Secondary', 'None')]
        [string]
        $RecordingTrack,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [MilestonePSTools.ValidateVmsVersion('23.2')]
        [MilestonePSTools.ValidateVmsFeature('MultistreamRecording')]
        [switch]
        $PlaybackDefault,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [switch]
        $UseEdge,

        [Parameter(ParameterSetName = 'AddOrUpdateStream')]
        [hashtable]
        $Settings
    )

    begin {
        Assert-VmsRequirementsMet
    }

    end {
        $recordingTrackId = @{
            Primary   = '16ce3aa1-5f93-458a-abe5-5c95d9ed1372'
            Secondary = '84fff8b9-8cd1-46b2-a451-c4a87d4cbbb0'
            None      = ''
        }
        foreach ($currentStream in $input) {
            # Use only for $PSCmdlet.ShouldProcess
            $targetName = "$($currentStream.Name) on $($currentStream.Camera.Name)"

            # Disable stream
            if ($Disabled) {
                if ($PSCmdlet.ShouldProcess($targetName, 'Remove')) {
                    $currentStream.Enabled = $false
                }
                continue
            }

            # Add stream
            $parametersRequiringStreamUsage = @('DisplayName', 'LiveDefault', 'LiveMode', 'PlaybackDefault', 'Recorded', 'RecordingTrack', 'UseEdge')
            $streamUsageRequired = $null -ne ($PSCmdlet.MyInvocation.BoundParameters.Keys | Where-Object { $_ -in $parametersRequiringStreamUsage })
            if (!$currentStream.Enabled -and $streamUsageRequired) {
                if ($PSCmdlet.ShouldProcess($targetName, 'Adding a new stream usage')) {
                    $currentStream.Enabled = $true
                }
            }

            foreach ($usagePropertyName in $parametersRequiringStreamUsage) {
                $paramValue = $PSCmdlet.MyInvocation.BoundParameters[$usagePropertyName]
                if (!$PSCmdlet.MyInvocation.BoundParameters.ContainsKey($usagePropertyName)) {
                    continue
                }
                if ($paramValue -ceq $currentStream.$usagePropertyName) {
                    continue
                }
                if ($PSCmdlet.ShouldProcess($targetName, "Set $usagePropertyName to $paramValue")) {
                    $currentStream.$usagePropertyName = $paramValue
                }
            }

            foreach ($key in $Settings.Keys) {
                if (!$currentStream.Settings.ContainsKey($key)) {
                    Write-Warning "A setting with the key '$key' was not found on $targetName"
                    continue
                } elseif ($currentStream.Settings[$key] -ceq $Settings[$key]) {
                    continue
                }
                if ($PSCmdlet.ShouldProcess($targetName, "Change $key from $($currentStream.Settings[$key]) to $($Settings[$key])")) {
                    $null = $currentStream.SetValue($key, $Settings[$key])
                }
            }


            if ($RecordingTrack -eq 'Secondary' -and $currentStream.RecordToValues.Count -eq 0) {
                Write-Warning 'Adaptive playback is not available. RecordingTrack parameter must be Primary or None.'
            }

            
            
            # Add stream or update stream usage properties
            # Can call Save() on Camera.StreamFolder.Streams object after changing one of the StreamUsageChildItems
            # Remove stream
            # Modify stream settings

            if ($currentStream.Dirty) {
                try {
                    $currentStream.Save()
                } catch [VideoOS.Platform.Proxy.ConfigApi.ValidateResultException] {
                    # Call Update to refresh all properties with values from server
                    $currentStream.Update()
                    $errorText = $_.Exception.ValidateResult.ErrorResults.ErrorText
                    $errorId = $_.Exception.ValidateResult.ErrorResults.ErrorTextId
                    #Write-Error -Message $errorText -ErrorId $errorId -Exception $_.Exception -TargetObject $currentStream
                    $_ | HandleValidateResultException -TargetObject $currentStream
                }
                
            }

            if ($PassThru) {
                $currentStream
            }
        }
    }
}
