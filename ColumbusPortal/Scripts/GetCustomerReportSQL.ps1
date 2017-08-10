[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$Config = Get-SQLENTConfig -Organization $Organization

Get-SQLTenantBillingInformation -Organization $Organization
