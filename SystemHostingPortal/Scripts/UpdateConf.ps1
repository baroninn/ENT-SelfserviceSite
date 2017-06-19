[Cmdletbinding()]
param (
    [parameter(mandatory)]
    [string]$Organization,
    [string]$ExchangeServer,
    [string]$DomainFQDN,
    [string]$NETBIOS,
    [string]$CustomerOUDN,
    [string[]]$Domains,
    [string]$TenantID365,
    [string]$AdminUser365,
    [string]$AdminPass365,
    [string]$AADsynced,
    [string]$ADConnectServer,
    [string]$DomainDC

)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot "Functions")

Set-EntConfig -Organization $Organization `
              -ExchangeServer $ExchangeServer `
              -DomainFQDN $DomainFQDN `
              -NetBios $NETBIOS `
              -CustomerOUDN $CustomerOUDN `
              -Domains $Domains `
              -TenantID365 $TenantID365 `
              -AdminUser365 $AdminUser365 `
              -AdminPass365 $AdminPass365 `
              -AADsynced $AADsynced `
              -ADConnectServer $ADConnectServer `
              -DomainDC $DomainDC