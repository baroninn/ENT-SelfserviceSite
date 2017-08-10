[Cmdletbinding()]
param (
    [parameter(mandatory)]
    [string]$Organization,
    [string]$Name,
    [string]$UserContainer,
    [string]$ExchangeServer,
    [string]$DomainFQDN,
    [string]$NETBIOS,
    [string]$CustomerOUDN,
    [string]$AdminUserOUDN,
    [string]$ExternalUserOUDN,
    [string[]]$EmailDomains,
    [string]$TenantID,
    [string]$AdminUser,
    [string]$AdminPass,
    [string]$AADsynced,
    [string]$ADConnectServer,
    [string]$DomainDC,
    [string]$NavMiddleTier,
    [string]$SQLServer,
    [string]$AdminRDS,
    [string]$AdminRDSPort

)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot "Functions")


Set-SQLEntConfig -Organization $Organization `
                  -Name $Name `
                  -UserContainer $UserContainer `
                  -ExchangeServer $ExchangeServer `
                  -DomainFQDN $DomainFQDN `
                  -NetBios $NETBIOS `
                  -CustomerOUDN $CustomerOUDN `
                  -AdminUserOUDN $AdminUserOUDN `
                  -ExternalUserOUDN $ExternalUserOUDN `
                  -EmailDomains $EmailDomains `
                  -TenantID $TenantID `
                  -AdminUser $AdminUser `
                  -AdminPass $AdminPass `
                  -AADsynced $AADsynced `
                  -ADConnectServer $ADConnectServer `
                  -DomainDC $DomainDC `
                  -NavMiddleTier $NavMiddleTier `
                  -SQLServer $SQLServer `
                  -AdminRDS $AdminRDS `
                  -AdminRDSPort $AdminRDSPort