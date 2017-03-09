param(
    [parameter(Mandatory=$true)]
    $Organization = 'ASG',
    [parameter(Mandatory=$true)]
    $DistinguishedName = 'CN=jstest,OU=Users,OU=Local Admins,OU=Accounts,DC=asgdom,DC=local',
    [switch]$Confirm = $true
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)


$Config = Get-EntConfig -Organization $Organization -JSON

$Cred  = Get-RemoteCredentials -Organization $Organization


if($Confirm) {
    
    if($Organization -eq "ASG"){
        $user = @(Get-ADUser -Credential $Cred -Server "$Organization-DC01.$($Config.DomainFQDN)" -Identity $DistinguishedName)
        Disable-ADAccount -Identity $DistinguishedName -Server "$Organization-DC01.$($Config.DomainFQDN)" -Credential $Cred
    }
    else{
        $user = @(Get-ADUser -Credential $Cred -Server "$Organization-DC-01.$($Config.DomainFQDN)" -Identity $DistinguishedName)
        Disable-ADAccount -Identity $DistinguishedName -Server "$Organization-DC-01.$($Config.DomainFQDN)" -Credential $Cred
    }

}