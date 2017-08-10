[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,
    [Parameter(Mandatory)]
    [string]$UserPrincipalName,
    [Parameter(Mandatory)]
    [string]$Password,
    [Parameter(Mandatory)]
    [switch]$PasswordNeverExpires
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$Config = Get-SQLENTConfig -Organization $Organization
$Cred = Get-RemoteCredentials -Organization $Organization

if(-not $PasswordNeverExpires) {
    $USer = Get-ADUser -filter {UserPrincipalName -eq $UserPrincipalName} -Server $config.DomainFQDN -Credential $Cred
    Set-ADAccountPassword -Identity $User.DistinguishedName -NewPassword ($Password | ConvertTo-SecureString -AsPlainText -Force) -Server $Config.DomainFQDN -Credential $Cred
    
    if ($Config.AADsynced -eq 'true') {
        Start-Dirsync -Organization $Organization
        Write-Output "Directory sync has been initiated, because the customer has Office365."
    }

}else{
    $USer = Get-ADUser -filter {UserPrincipalName -eq $UserPrincipalName} -Server $config.DomainFQDN -Credential $Cred
    Set-ADAccountPassword -Identity $User.DistinguishedName -NewPassword ($Password | ConvertTo-SecureString -AsPlainText -Force) -Server $Config.DomainFQDN -Credential $Cred
    Set-ADUser -Identity $User.DistinguishedName -Server $Config.DomainFQDN -Credential $Cred -PasswordNeverExpires $true

    if ($Config.AADsynced -eq 'true') {
        Start-Dirsync -Organization $Organization -Policy 'delta'
        Write-Output "Directory sync has been initiated, because the customer has Office365."
    }
}
