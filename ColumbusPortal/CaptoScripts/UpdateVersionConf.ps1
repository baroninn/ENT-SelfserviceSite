[Cmdletbinding()]
param (
    
    [string]$Organization,

    [switch]$Force,

    [bool]$UpdateAll

)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot "Capto")

if(-not $UpdateAll) {
    Update-VersionConf -TenantName $Organization
}
if ($UpdateAll) {
    $Orgs = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk" -SearchScope OneLevel -Server hosting.capto.dk | select -ExpandProperty Name

    foreach ($i in $Orgs) {
        Update-VersionConf -TenantName $i
    }
}