[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]
    $Name
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

Import-Module (New-ExchangeProxyModule -Command "Get-MobileDeviceStatistics")

$mbx = Get-TenantMailbox -TenantName $Organization -Name $Name -Single

if ($mbx -ne $null) {
    $stats = Get-MobileDeviceStatistics -Mailbox $mbx.DistinguishedName
    $stats = $stats | select DeviceType,DeviceFriendlyName,DeviceOS,LastSyncAttemptTime,Lastsuccesssync | Sort LastSuccessSync -Descending
    $html = $stats | ConvertTo-HTML -Fragment

    return $html
}
else {
    Write-Error "No mailbox found for '$Organization' with Name '$Name'."
}