[Cmdletbinding()]
param(
    [Parameter(Mandatory)]
    [string]
    $Organization,
    [Parameter(Mandatory)]
    [string]
    $domain
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot Functions)

$Config = Get-Content (Join-Path $PSScriptRoot "Functions\Config\$Organization\$Organization.txt") -Raw | ConvertFrom-Json

$Config = Get-TenantConfig -TenantName $Organization

Add-UPNSuffix -TenantName $Organization -domain $domain -TenantID $Config.TenantID365.ID