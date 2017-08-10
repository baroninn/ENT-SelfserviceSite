[Cmdletbinding()]
param (
    [parameter(mandatory)]
    [string]$Organization,
    [parameter(mandatory)]
    [string]$Name,
    [string]$NavMiddleTier,
    [string]$SQLServer
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

Update-SQLSharedCustomerConfig -Organization $Organization -Name $Name -NavMiddleTier $NavMiddleTier -SQLServer $SQLServer