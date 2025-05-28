Context 'Restricted Media' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        $script:RestrictedMediaPrefix = 'PESTER'
        Get-VmsRestrictedMedia -Live | Remove-VmsRestrictedMedia -Confirm:$false
    }

    AfterAll {
        $pattern = '^{0}' -f $script:RestrictedMediaPrefix
        Get-VmsRestrictedMedia | Where-Object Header -CMatch $pattern | Remove-VmsRestrictedMedia -Confirm:$false
        Get-VmsRestrictedMedia -Live | Remove-VmsRestrictedMedia -Confirm:$false
    }

    Describe 'New-VmsRestrictedMedia' {
        It 'Can create new media restriction' {
            $camera = Get-VmsCamera | Select-Object -First 1
            $splat = @{
                Header    = '{0} Can create new restricted playback' -f $script:RestrictedMediaPrefix
                StartTime = (Get-Date).AddDays(-1)
                EndTime   = (Get-Date).Date
            }

            $restriction = $camera | New-VmsRestrictedMedia @splat
            $restriction.GetType().FullName | Should -BeExactly 'VideoOS.Common.Proxy.Server.WCF.RestrictedMedia'
            $restriction.Header | Should -BeExactly $splat.Header
            $restriction.StartTime.ToLocalTime() | Should -Be $splat.StartTime
            $restriction.EndTime.ToLocalTime() | Should -Be $splat.EndTime
        }
    }

    Describe 'Get-VmsRestrictedMedia' {
        It 'Can get playback restrictions' {
            $camera = Get-VmsCamera | Select-Object -First 1
            $splat = @{
                Header    = '{0} Get-VmsRestrictedMedia {1}' -f $script:RestrictedMediaPrefix, (New-Guid)
                StartTime = (Get-Date).AddDays(-1)
                EndTime   = (Get-Date).Date
            }
            $null = $camera | New-VmsRestrictedMedia @splat
            $restriction = Get-VmsRestrictedMedia | Where-Object Header -CEQ $splat.Header
            $restriction | Should -Not -BeNullOrEmpty
            $restriction.Header | Should -BeExactly $splat.Header
            $camera.Id | Should -BeIn $restriction.DeviceIds
        }
    }

    Describe 'Start-VmsRestrictedLiveMode' {
        It 'Can create new live media restriction' {
            $startTime = (Get-Date).AddMinutes(-15)
            $camera = Get-VmsCamera | Select-Object -First 1
            
            $restriction = $camera | Start-VmsRestrictedLiveMode -StartTime $startTime
            $restriction.GetType().FullName | Should -BeExactly 'VideoOS.Common.Proxy.Server.WCF.RestrictedMediaLive'
            $restriction.StartTime.ToLocalTime() | Should -BeExactly $startTime
            $restriction.DeviceId | Should -Be $camera.Id
        }
    }

    Describe 'Stop-VmsRestrictedLiveMode' {
        It 'Can exit live media restriction' {
            $startTime = (Get-Date).AddMinutes(-15)
            $camera = Get-VmsCamera | Select-Object -First 1
            $restriction = $camera | Start-VmsRestrictedLiveMode -StartTime $startTime
            
            $splat = @{
                Header      = '{0} Stop-VmsRestrictedLiveMode' -f $script:RestrictedMediaPrefix
                Description = New-Guid
                StartTime   = $startTime
                EndTime     = $startTime.AddMinutes(5)
            }
            $playbackRestriction = $restriction | Stop-VmsRestrictedLiveMode @splat
            $playbackRestriction.GetType() | Should -BeExactly 'VideoOS.Common.Proxy.Server.WCF.RestrictedMedia'
            $playbackRestriction.Header | Should -BeExactly $splat.Header
            $playbackRestriction.Description | Should -BeExactly $splat.Description
            $playbackRestriction.StartTime | Should -BeExactly $splat.StartTime.ToUniversalTime()
            $playbackRestriction.EndTime | Should -BeExactly $splat.EndTime.ToUniversalTime()
        }
    }

    Describe 'Remove-VmsRestrictedMedia' {
        It 'Can remove media restriction' {
            $camera = Get-VmsCamera | Select-Object -First 1
            $splat = @{
                Header    = '{0} Can remove media restriction' -f $script:RestrictedMediaPrefix
                StartTime = (Get-Date).AddDays(-1)
                EndTime   = (Get-Date).Date
            }

            $restriction = $camera | New-VmsRestrictedMedia @splat
            $restriction | Remove-VmsRestrictedMedia -Confirm:$false
            Get-VmsRestrictedMedia | Where-Object Id -EQ $restriction.Id | Should -BeNullOrEmpty
        }

        It 'Can remove live media restriction' {
            $startTime = (Get-Date).AddMinutes(-15)
            $camera = Get-VmsCamera | Select-Object -First 1
            
            $restriction = $camera | Start-VmsRestrictedLiveMode -StartTime $startTime
            $restriction | Should -Not -BeNullOrEmpty
            $camera | Remove-VmsRestrictedMedia -Confirm:$false
            Get-VmsRestrictedMedia -Live | Where-Object DeviceId -EQ $camera.Id | Should -BeNullOrEmpty
        }
    }

    Describe 'Set-VmsRestrictedMedia' {
        It 'Can update restricted media' {
            $camera = Get-VmsCamera | Select-Object -First 1
            $splat = @{
                Header    = '{0} Can update restricted media' -f $script:RestrictedMediaPrefix
                StartTime = (Get-Date).AddDays(-1)
                EndTime   = (Get-Date).Date
            }

            $restriction = $camera | New-VmsRestrictedMedia @splat
            $restriction | Should -Not -BeNullOrEmpty
            
            $splat = @{
                Header      = '{0} {1}' -f $splat.Header, (New-Guid)
                Description = New-Guid
                StartTime   = (Get-Date).AddDays(-7)
                EndTime     = (Get-Date).AddDays(-6)
                PassThru    = $true
            }
            
            $updatedRestriction = $restriction | Set-VmsRestrictedMedia @splat
            $updatedRestriction.GetType().FullName | Should -BeExactly $restriction.GetType().FullName
            $updatedRestriction.Header | Should -BeExactly $splat.Header
            $updatedRestriction.Description | Should -BeExactly $splat.Description
            $updatedRestriction.StartTime | Should -BeExactly $splat.StartTime.ToUniversalTime()
            $updatedRestriction.EndTime | Should -BeExactly $splat.EndTime.ToUniversalTime()
        }
    }
}
