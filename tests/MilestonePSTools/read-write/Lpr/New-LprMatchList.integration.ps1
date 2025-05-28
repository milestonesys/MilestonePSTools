Context 'LPR' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        Get-VmsLprMatchList | Remove-VmsLprMatchList -Confirm:$false
    }

    Describe 'New-VmsLprMatchList' {
        It 'Can create new lpr match list' {
            $name = (New-Guid).ToString()
            $list = New-VmsLprMatchList -Name $name -ErrorAction Stop
            $list.Name | Should -BeExactly $name
        }

        It 'Can create new lpr match list by property name' {
            $record = [pscustomobject]@{
                Name           = (New-Guid).ToString()
                ExtraParameter = $null
            }
            $list = $record | New-VmsLprMatchList -ErrorAction Stop
            $list.Name | Should -BeExactly $record.Name
        }

        ## TODO: Add tests for creating a new match list with trigger events
    }

    Describe 'Get-VmsLprMatchList' {
        It 'Can get match list by name' {
            $name = 'Unlisted license plate'
            $list = Get-VmsLprMatchList -Name $Name
            $list.Name | Should -BeExactly $name
        }

        It 'Can get match lists by name with wildcard' {
            $lists = Get-VmsLprMatchList -Name *
            $lists.Count | Should -BeGreaterThan 0
        }

        It 'Can get new match list without clearing cache' {
            $name = New-Guid
            $null = New-VmsLprMatchList -Name $name
            (Get-VmsLprMatchList -Name $name).Name | Should -BeExactly $name.ToString()
        }

        It 'Can get all match lists' {
            $ms = Get-VmsManagementServer
            $ms.LprMatchListFolder.ClearChildrenCache()
            (Get-VmsLprMatchList).Count | Should -Be $ms.LprMatchListFolder.LprMatchLists.Count
        }
    }
}
