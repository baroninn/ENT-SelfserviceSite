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
Import-Module (Join-Path $PSScriptRoot Capto)

Add-UPNSuffix -TenantName $Organization -domain $domain