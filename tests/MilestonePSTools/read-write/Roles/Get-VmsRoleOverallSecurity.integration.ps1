Context 'Get-VmsRoleOverallSecurity' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        (Get-VmsManagementServer).RoleFolder.ClearChildrenCache()
        Get-VmsRole -RoleType UserDefined | Remove-VmsRole -Confirm:$false
        $script:role = New-VmsRole -Name 'Get-VmsRoleOverallSecurity Test Role' -PassThru
    }

    It 'Can get all security namespace attributes' {
        $overallSecurity = $script:role | Get-VmsRoleOverallSecurity
        $overallSecurity.Count | Should -BeGreaterThan 1
    }

    It 'Can get overall security namespace by name' {
        $cameraAttributes = $script:role | Get-VmsRoleOverallSecurity -SecurityNamespace Cameras
        $cameraAttributes.Keys.Count | Should -BeGreaterThan 0
        $cameraAttributes.SecurityNamespace | Should -Be '623d03f8-c5d5-46bc-a2f4-4c03562d4f85'
    }

    It 'Can get overall security namespace by id' {
        $cameraAttributes = $script:role | Get-VmsRoleOverallSecurity -SecurityNamespace 623d03f8-c5d5-46bc-a2f4-4c03562d4f85
        $cameraAttributes.Keys.Count | Should -BeGreaterThan 0
        $cameraAttributes.SecurityNamespace | Should -Be '623d03f8-c5d5-46bc-a2f4-4c03562d4f85'
    }
}
