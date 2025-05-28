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

function Set-CertKeyPermission {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # Specifies the certificate store path to locate the certificate specified in Thumbprint. Example: Cert:\LocalMachine\My
        [Parameter()]
        [string]
        $CertificateStore = 'Cert:\LocalMachine\My',

        # Specifies the thumbprint of the certificate to which private key access should be updated.
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Thumbprint,

        # Specifies the Windows username for the identity to which permissions should be granted.
        [Parameter(Mandatory)]
        [string]
        $UserName,

        # Specifies the level of access to grant to the private key.
        [Parameter()]
        [ValidateSet('Read', 'FullControl')]
        [string]
        $Permission = 'Read',

        # Specifies the access type for the Access Control List rule.
        [Parameter()]
        [ValidateSet('Allow', 'Deny')]
        [string]
        $PermissionType = 'Allow'
    )

    process {
        <#
            There is a LOT of error checking in this function as it seems that certificates are not
            always consistently storing their private keys in predictable places. I've found private
            keys for RSA certs in ProgramData\Microsoft\Crypto\Keys instead of
            ProgramData\Microsoft\Crypto\RSA\MachineKeys, I've seen the UniqueName property contain
            a value representing the file name of the certificate private key file somewhere in the
            ProgramData\Microsoft\Crypto folder, and I've seen the UniqueName property contain a
            full file path to the private key file. I've also found that some RSA certs require you
            to use the RSA extension method to retrieve the private key, even though it seems like
            you should expect to find it in the PrivateKey property when retrieving the certificate
            from Get-ChildItem Cert:\LocalMachine\My.
        #>

        $certificate = Get-ChildItem -Path $CertificateStore | Where-Object Thumbprint -eq $Thumbprint
        Write-Verbose "Processing certificate for $($certificate.Subject) with thumbprint $($certificate.Thumbprint)"
        if ($null -eq $certificate) {
            Write-Error "Certificate not found in certificate store '$CertificateStore' matching thumbprint '$Thumbprint'"
            return
        }
        if (-not $certificate.HasPrivateKey) {
            Write-Error "Certificate with friendly name '$($certificate.FriendlyName)' issued to subject '$($certificate.Subject)' does not have a private key attached."
            return
        }
        $privateKey = $null
        switch ($certificate.PublicKey.EncodedKeyValue.Oid.FriendlyName) {
            'RSA' {
                $privateKey = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($certificate)
            }

            'ECC' {
                $privateKey = [System.Security.Cryptography.X509Certificates.ECDsaCertificateExtensions]::GetECDsaPrivateKey($certificate)
            }

            'DSA' {
                Write-Error "Use of DSA-based certificates is not recommended, and not supported by this command. See https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.dsa?view=net-5.0"
                return
            }

            Default { Write-Error "`$certificate.PublicKey.EncodedKeyValue.Oid.FriendlyName was '$($certificate.PublicKey.EncodedKeyValue.Oid.FriendlyName)'. Expected RSA, DSA or ECC."; return }
        }
        if ($null -eq $privateKey) {
            Write-Error "Certificate with friendly name '$($certificate.FriendlyName)' issued to subject '$($certificate.Subject)' does not have a private key attached."
            return
        }
        if ([string]::IsNullOrWhiteSpace($privateKey.Key.UniqueName)) {
            Write-Error "Certificate with friendly name '$($certificate.FriendlyName)' issued to subject '$($certificate.Subject)' does not have a value for the private key's UniqueName property so we cannot find the file on the filesystem associated with the private key."
            return
        }

        if (Test-Path -LiteralPath $privateKey.Key.UniqueName) {
            $privateKeyFile = Get-Item -Path $privateKey.Key.UniqueName
        }
        else {
            $privateKeyFile = Get-ChildItem -Path (Join-Path -Path ([system.environment]::GetFolderPath([system.environment+specialfolder]::CommonApplicationData)) -ChildPath ([io.path]::combine('Microsoft', 'Crypto'))) -Filter $privateKey.Key.UniqueName -Recurse -ErrorAction Ignore
            if ($null -eq $privateKeyFile) {
                Write-Error "No private key file found matching UniqueName '$($privateKey.Key.UniqueName)'"
                return
            }
            if ($privateKeyFile.Count -gt 1) {
                Write-Error "Found more than one private key file matching UniqueName '$($privateKey.Key.UniqueName)'"
                return
            }
        }

        $privateKeyPath = $privateKeyFile.FullName
        if (-not (Test-Path -Path $privateKeyPath)) {
            Write-Error "Expected to find private key file at '$privateKeyPath' but the file does not exist. You may need to re-install the certificate in the certificate store"
            return
        }

        $acl = Get-Acl -Path $privateKeyPath
        $rule = [Security.AccessControl.FileSystemAccessRule]::new($UserName, $Permission, $PermissionType)
        $acl.AddAccessRule($rule)
        if ($PSCmdlet.ShouldProcess($privateKeyPath, "Add FileSystemAccessRule")) {
            $acl | Set-Acl -Path $privateKeyPath
        }
    }
}

