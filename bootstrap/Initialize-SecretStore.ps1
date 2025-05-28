if ($env:VAULT_PASSWORD_DEFAULT) {
    $password = $env:VAULT_PASSWORD_DEFAULT | ConvertTo-SecureString -AsPlainText -Force
    if ($null -eq (Get-SecretVault)) {
        Register-SecretVault -ModuleName Microsoft.PowerShell.SecretStore -Name SecretStore -DefaultVault -ErrorAction Stop
        $secretStoreParams = @{
            Authentication = 'Password'
            Scope          = 'CurrentUser'
            Interaction    = 'None'
            Confirm        = $false
            Password       = $password
        }
        Set-SecretStoreConfiguration @secretStoreParams
    }
    Unlock-SecretStore -Password $password -PasswordTimeout (60 * 60)

    foreach ($var in Get-ChildItem env:\MilestonePSTools.*) {
        $value = $var.Value
        if ($var.Name -like '*Credential*') {
            $text = [text.encoding]::UTF8.GetString([convert]::FromBase64String($value))
            $username, $password = $text -split ':', 2
            $value = [pscredential]::new($username, ($password | ConvertTo-SecureString -AsPlainText -Force))
        }
        Set-Secret -Name $var.Name -Secret $value
    }
}
