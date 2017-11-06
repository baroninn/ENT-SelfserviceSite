function Reset-AdminUserPassword {
    [cmdletbinding()]
    param(
        [parameter(mandatory)]
        [string]$SamAccountName,
        [parameter(mandatory)]
        [string]$Password
    )

    begin{
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        $AdminUsers = Get-AdminUserConfig
        $User = $AdminUsers | where {$_.SamAccountName -eq $SamAccountName}
    }
    process{

        $Organizations = Get-Organizations

        foreach ($org in $Organizations) {
            Write-Verbose "updating $org"
            $Config = Get-SQLEntConfig -Organization $org
            $Cred = Get-RemoteCredentials -Organization $org

            try {
            $userexist = Get-ADUser -Server $Config.DomainDC -SearchBase $Config.AdminUserOUDN -Credential $Cred -Filter "sAMAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue
                if ($userexist) {
                    $userexist | Set-ADAccountPassword -NewPassword (ConvertTo-SecureString -String $Password -AsPlainText -Force) -Server $Config.DomainDC -Credential $Cred
                    Write-Output "Password for $SamAccountName has been changed at $org"
                }
                else {
                    $ADUser = New-ADUser -GivenName $User.FirstName `
                                         -Surname $USer.LastName `
                                         -SamAccountName $SamAccountName `
                                         -Name $User.DisplayName `
                                         -Server $Config.DomainDC `
                                         -Credential $Cred `
                                         -Path $Config.AdminUserOUDN `
                                         -Enabled $true `
                                         -UserPrincipalName "$($SamAccountName)@$($Config.DomainFQDN)" `
                                         -AccountPassword (ConvertTo-SecureString -String $Password -AsPlainText -Force) `
                                         -PasswordNeverExpires $true
                    Add-ADGroupMember -Identity "Domain Admins" -Members $SamAccountName -Server $Config.DomainDC -Credential $Cred
                    Write-Output "Created Admin at $Org"
                }
            }
            catch {
                Write-Output "ERROR with $($org): $_"
            }
        }
    }
}