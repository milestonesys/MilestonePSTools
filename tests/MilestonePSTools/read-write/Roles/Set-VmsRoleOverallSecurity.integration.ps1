Context 'Set-VmsRoleOverallSecurity' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        (Get-VmsManagementServer).RoleFolder.ClearChildrenCache()
        Get-VmsRole -RoleType UserDefined | Remove-VmsRole -Confirm:$false
        $script:role = New-VmsRole -Name 'Set-VmsRoleOverallSecurity Test Role' -PassThru
    }

    It 'Can get and set all overall security namespaces' {
        $overallSecurity = $script:role | Get-VmsRoleOverallSecurity
        $overallSecurity.Count | Should -BeGreaterThan 1
        {
            $overallSecurity | ForEach-Object {
                $permissions = $_
                ($permissions.Keys | Select-Object) | ForEach-Object {
                    $key = $_
                    switch ($permissions[$key]) {
                        'None'  { $permissions[$key] = 'Allow' }
                        'Allow' { $permissions[$key] = 'Deny' }
                        'Deny'  { $permissions[$key] = 'None' }
                    }
                }
                $script:role | Set-VmsRoleOverallSecurity -Permissions $permissions
            }
        } | Should -Not -Throw
    }

    It 'Can get and set security namespaces with only Permissions parameter' {
        $permissions = $script:role | Get-VmsRoleOverallSecurity -SecurityNamespace Cameras
        {
            ($permissions.Keys | Select-Object) | ForEach-Object {
                $key = $_
                switch ($permissions[$key]) {
                    'None'  { $permissions[$key] = 'Allow' }
                    'Allow' { $permissions[$key] = 'Deny' }
                    'Deny'  { $permissions[$key] = 'None' }
                }
            }
            Set-VmsRoleOverallSecurity -Permissions $permissions
        } | Should -Not -Throw
    }

    It 'Can modify a single attribute of a single security namespace by name' {
        $cameras = $script:role | Get-VmsRoleOverallSecurity -SecurityNamespace Cameras
        $namespaceName = 'Cameras'
        $key = 'GENERIC_WRITE'
        $newValue = if ($cameras[$key] -eq 'None') { 'Allow' } else { 'None' }
        $script:role | Set-VmsRoleOverallSecurity -SecurityNamespace $namespaceName -Permissions (@{"$key" = $newValue})

        ($script:role | Get-VmsRoleOverallSecurity -SecurityNamespace $namespaceName).$key | Should -Be $newValue
    }

    It 'Can modify a single attribute of a single security namespace by id' {
        $cameras = $script:role | Get-VmsRoleOverallSecurity -SecurityNamespace Cameras
        $namespaceId = '623d03f8-c5d5-46bc-a2f4-4c03562d4f85'
        $key = 'GENERIC_WRITE'
        $newValue = if ($cameras[$key] -eq 'None') { 'Allow' } else { 'None' }
        $script:role | Set-VmsRoleOverallSecurity -SecurityNamespace $namespaceId -Permissions (@{"$key" = $newValue})

        ($script:role | Get-VmsRoleOverallSecurity -SecurityNamespace $namespaceId).$key | Should -Be $newValue
    }
}
