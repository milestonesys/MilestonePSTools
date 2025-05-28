Context 'Import-VmsRole' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        (Get-VmsManagementServer).RoleFolder.ClearChildrenCache()
        Get-VmsRole -RoleType UserDefined | Remove-VmsRole -Confirm:$false
        1..4 | Foreach-Object {
            $null = New-VmsRole -Name "Role $_" -Description "Role $_ description"
        }
    }

    It 'Can update existing roles' {
        $userDefinedRoles = @{}
        Get-VmsRole -RoleType UserDefined | Foreach-Object {
            $userDefinedRoles[$_.Name] = $_.Description
        }

        $path = Join-Path -Path ([io.path]::GetTempPath()) -ChildPath 'Import-VmsRole1.json'
        try {
            Get-VmsRole -RoleType UserDefined | Export-VmsRole -Path $path
            Get-VmsRole -RoleType UserDefined | Foreach-Object {
                $_ | Set-VmsRole -Description (New-Guid)
            }
            $null = Import-VmsRole -Path $path -Force
            (Get-VmsManagementServer).RoleFolder.ClearChildrenCache()
            foreach ($role in Get-VmsRole -RoleType UserDefined) {
                $role.Description | Should -BeExactly $userDefinedRoles[$role.Name]
            }
        } finally {
            Remove-Item -Path $path
        }
    }

    It 'Can recreate client profiles' {
        $originalCount = (Get-VmsRole).Count
        $path = Join-Path -Path ([io.path]::GetTempPath()) -ChildPath 'Import-VmsRole1.json'
        try {
            Get-VmsRole -RoleType UserDefined | Export-VmsRole -Path $path
            Get-VmsRole -RoleType UserDefined | Remove-VmsRole -Confirm:$false
            $null = Import-VmsRole -Path $path
            (Get-VmsManagementServer).RoleFolder.ClearChildrenCache()
            (Get-VmsRole).Count | Should -Be $originalCount
        } finally {
            Remove-Item -Path $path
        }
    }
}
