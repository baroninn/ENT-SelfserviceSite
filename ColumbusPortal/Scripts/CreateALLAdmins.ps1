[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization

)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

Import-Module (Join-Path $PSScriptRoot "Functions")

$AdminUsers = Get-AdminUserConfig

Write-Verbose "updating $Organization"
foreach ($AdminUser in $AdminUsers) {
    $Config = Get-SQLEntConfig -Organization $Organization
    $Cred = Get-RemoteCredentials -Organization $Organization

    try {
    $userexist = Get-ADUser -Server $Config.DomainDC -SearchBase $Config.AdminUserOUDN -Credential $Cred -Filter "sAMAccountName -eq '$($AdminUser.SamAccountName)'" -ErrorAction SilentlyContinue
        if ($userexist) {
            Write-Verbose "$($userexist.SamAccountName) already exist, skipping.."
        }
        else {
            $ADUser = New-ADUser -GivenName $AdminUser.FirstName `
                                    -Surname $AdminUser.LastName `
                                    -SamAccountName $AdminUser.SamAccountName `
                                    -Name $AdminUser.DisplayName `
                                    -Server $Config.DomainDC `
                                    -Credential $Cred `
                                    -Path $Config.AdminUserOUDN `
                                    -Enabled $true `
                                    -UserPrincipalName "$($AdminUser.SamAccountName)@$($Config.DomainFQDN)" `
                                    -AccountPassword (ConvertTo-SecureString -String 'Passw0rd20!5' -AsPlainText -Force) `
                                    -PasswordNeverExpires $true
            
            Add-ADGroupMember -Identity "Domain Admins" -Members $AdminUser.SamAccountName -Server $Config.DomainDC -Credential $Cred

            Write-Output "Created $($AdminUser.DisplayName) at $Organization"

        }
    }
    catch {
        throw "ERROR on Organization: $_"
    }
}

