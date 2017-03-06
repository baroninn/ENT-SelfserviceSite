[Cmdletbinding()]
param (
    [parameter(mandatory)]
    [string]$Organization,
    [string]$ExchangeServer,
    [string]$DomainFQDN,
    [string]$CustomerOUDN,
    [string[]]$AcceptedDomains,
    [string]$TenantID365,
    [string]$AdminUser365,
    [string]$AdminPass365

)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot "Functions")

Set-EntConfig -Organization $Organization -ExchangeServer $ExchangeServer -DomainFQDN $DomainFQDN -CustomerOUDN $CustomerOUDN -AcceptedDomains $AcceptedDomains -TenantID365 $TenantID365 -AdminUser365 $AdminUser365 -AdminPass365 $AdminPass365