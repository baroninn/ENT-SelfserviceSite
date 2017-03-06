[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,
    [Parameter(Mandatory)]
    [string]$DistinguishedName,
    [Parameter(Mandatory)]
    [string]$Password,
    [Parameter(Mandatory)]
    [switch]$PasswordNeverExpires
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$Config = Get-ENTConfig -Organization $Organization -JSON
$Cred = Get-RemoteCredentials -Organization $Organization

if(-not $PasswordNeverExpires) {
Set-ADAccountPassword -Identity $DistinguishedName -NewPassword ($Password | ConvertTo-SecureString -AsPlainText -Force) -Server ("$ORganization-dc-01.$($Config.DomainFQDN)") -Credential $Cred
}else{
Set-ADAccountPassword -Identity $DistinguishedName -NewPassword ($Password | ConvertTo-SecureString -AsPlainText -Force) -Server ("$ORganization-dc-01.$($Config.DomainFQDN)") -Credential $Cred
Set-ADUser -Identity $DistinguishedName -Server ("$ORganization-dc-01.$($Config.DomainFQDN)") -Credential $Cred -PasswordNeverExpires $true
}
