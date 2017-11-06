[Cmdletbinding()]
param (
    [parameter(mandatory)]
    [string]$Organization,
    [string]$Platform,
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
    [string]$AdminRDSPort,
    [string]$AppID,
    [string]$AppSecret,
    [bool]$ServiceCompute,
    [bool]$Service365,
    [bool]$serviceIntune

)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot "Functions")

$params = @{
    Organization     = $Organization
    Platform         = $Platform
    Name             = $Name
    UserContainer    = $UserContainer
    ExchangeServer   = $ExchangeServer
    DomainFQDN       = $DomainFQDN
    NetBios          = $NETBIOS
    CustomerOUDN     = $CustomerOUDN
    AdminUserOUDN    = $AdminUserOUDN
    ExternalUserOUDN = $ExternalUserOUDN
    EmailDomains     = $EmailDomains
    TenantID         = $TenantID
    AdminUser        = $AdminUser
    AdminPass        = $AdminPass
    AADsynced        = $AADsynced
    ADConnectServer  = $ADConnectServer
    DomainDC         = $DomainDC
    NavMiddleTier    = $NavMiddleTier
    SQLServer        = $SQLServer
    AdminRDS         = $AdminRDS
    AdminRDSPort     = $AdminRDSPort
    AppID            = $AppID
    AppSecret        = $AppSecret
}
if ($ServiceCompute) {
    $params.add("ServiceCompute", $true)
}
else {
    $params.add("ServiceCompute", $false)
}
if ($Service365) {
    $params.add("Service365", $true)
}
else {
    $params.add("Service365", $false)
}
if ($serviceIntune) {
    $params.add("ServiceIntune", $true)
}
else {
    $params.add("ServiceIntune", $false)
}

Set-SQLEntConfig @params