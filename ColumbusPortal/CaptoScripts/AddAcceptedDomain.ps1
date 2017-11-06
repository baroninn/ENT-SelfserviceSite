[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]
    $Domain,

    [bool]
    $SetAsUPN
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

if ($SetAsUPN) {
    Add-TenantDomain -TenantName $Organization -Domain $Domain -SetAsUPN
    }
else {
    Add-TenantDomain -TenantName $Organization -Domain $Domain
}