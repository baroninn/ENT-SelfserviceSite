param(
    [parameter(Mandatory=$true)]
    $Organization,
    [parameter(Mandatory=$true)]
    $UserPrincipalName,
    [switch]$Enable,
    [switch]$UnhideFromAddressList
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

if ($mbx.RecipientTypeDetails -ne "UserMailbox") {
    Write-Error "'$($mbx.DisplayName)' can not be enabled, because it is of type '$($mbx.RecipientTypeDetails)'. Only a mailbox of type 'UserMailbox' can be enabled."
}

if($Enable) {
    Enable-ADAccount -Identity $mbx.DistinguishedName -Server $Config.DomainFQDN
}

if($UnhideFromAddressList) {
    $mbx | Set-Mailbox -HiddenFromAddressListsEnabled $false
}