Context 'Export-VmsRole' -Skip:($script:SkipReadWriteTests) {
    BeforeAll {
        (Get-VmsManagementServer).RoleFolder.ClearChildrenCache()
        Get-VmsRole -RoleType UserDefined | Remove-VmsRole -Confirm:$false
        1..4 | Foreach-Object {
            $null = New-VmsRole -Name "Role $_" -Description "Role $_ description"
        }
    }

    It 'Can export all roles' {
        $roles = Get-VmsRole
        $path = Join-Path -Path ([io.path]::GetTempPath()) -ChildPath 'Export-VmsRole1.json'
        try {
            Export-VmsRole -Path $path
            (Get-Content -Path $path -Raw | ConvertFrom-Json).Count | Should -Be $roles.Count
        } finally {
            Remove-Item -Path $path
        }
    }

    It 'Can export one role' {
        $path = Join-Path -Path ([io.path]::GetTempPath()) -ChildPath 'Export-VmsRole2.json'
        try {
            Get-VmsRole -RoleType Adminstrative | Export-VmsRole -Path $path
            (Get-Content -Path $path -Raw | ConvertFrom-Json).Count | Should -Be 1
        } finally {
            Remove-Item -Path $path
        }
    }

    It 'Can export role by name' {
        $path = Join-Path -Path ([io.path]::GetTempPath()) -ChildPath 'Export-VmsRole3.json'
        try {
            $role = Get-VmsRole | Get-Random
            Export-VmsRole -Role $role.Name -Path $path
            (Get-Content -Path $path -Raw | ConvertFrom-Json).Count | Should -Be 1
        } finally {
            Remove-Item -Path $path
        }
    }

    It 'Can export roles as variable' {
        $role = Get-VmsRole | Get-Random
        $obj = $role | Export-VmsRole -PassThru
        $obj.Name | Should -BeExactly $role.Name
        $obj.Description | Should -BeExactly $role.Description
    }
}
