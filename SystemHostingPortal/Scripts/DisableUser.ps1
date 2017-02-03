param(
    [parameter(Mandatory=$true)]
    $Organization,
    [parameter(Mandatory=$true)]
    $UserPrincipalName,
    [switch]$Disable,
    [switch]$HideFromAddressList,
    [switch]$Delete
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

Import-Module (New-ExchangeProxyModule -Command "Set-Mailbox")

$Config = Get-TenantConfig -TenantName $Organization

$mbx = @(Get-TenantMailbox -TenantName $Organization -Name $UserPrincipalName)
if ($mbx.Count -eq 0) {
    Write-Error "No mailbox was found with UserPrincipalName '$UserPrincipalName'."
}
elseif ($mbx.Count -ne 1) {
	throw "Multiple mailboxes found from UserPrincipalName."
}

if($Disable) {
    Disable-ADAccount -Identity $mbx.DistinguishedName -Server $Config.DomainFQDN
    Set-Aduser -Identity $mbx.DistinguishedName -Server $Config.DomainFQDN -Add @{extensionAttribute12="Disabled"}

}

if($HideFromAddressList) {
    $mbx | Set-Mailbox -HiddenFromAddressListsEnabled $true
}