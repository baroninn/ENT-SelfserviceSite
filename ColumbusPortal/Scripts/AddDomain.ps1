[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,

    [Parameter(Mandatory)]
    [string]$Domain,

    [switch]$AddasEmail
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Config = Get-SQLEntConfig -Organization $Organization

if ($AddasEmail -and $config.ExchangeServer -eq $null -and $Config.TenantID -eq $null) {

    Throw "$Organization doesn't appear to have any mail service running.. Please check config if this is wrong.."
}
else {

    if ($AddasEmail) {
        Add-TenantDomain -Organization $Organization -Domain $Domain -AddasEmail
    }
    else {
        Add-TenantDomain -Organization $Organization -Domain $Domain
    }
}