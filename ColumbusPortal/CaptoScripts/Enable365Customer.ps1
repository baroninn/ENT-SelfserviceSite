[Cmdletbinding()]
param(
    [Parameter(Mandatory)]
    [string]
    $Organization,
    [Parameter(Mandatory)]
    [string]
    $tenantid,
    [Parameter(Mandatory)]
    [string]
    $tenantAdmin,
    [Parameter(Mandatory)]
    [string]
    $tenantPass
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot Capto)

$Config = Get-TenantConfig -TenantName $Organization

$json = (Get-ADOrganizationalUnit -Server $Config.DomainFQDN -Identity $config.OUs[1].Path -Properties adminDescription).adminDescription
$obj = ConvertFrom-Json -InputObject $json

Set-TenantConfig -TenantName $Organization -Product $Config.Product.Name -FileServer $obj.FileServer.Name -FileServerDriveLetter $obj.FileServer.DriveLetter -TenantID365 $tenantid -TenantAdmin $tenantAdmin -TenantPass $tenantPass

if ($tenantid -eq '43eea929-d726-4742-83a9-603c12a0d195') {

    $users = Get-ADUser -Filter * -SearchBase ("OU=" + $Config.OUs[1].Name + "," + $Config.OUs[1].Path) -Server $config.DomainFQDN -Properties extensionAttribute11

    foreach($i in $users) {
        if ($i.extensionAttribute11 -eq "User_DoNotSync") {

        Set-ADUser -Identity $i -Server $Config.DomainFQDN -Remove @{extensionAttribute11="User_DoNotSync"}
        }
    }
}