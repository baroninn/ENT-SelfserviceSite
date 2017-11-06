[Cmdletbinding()]
param (
    [parameter(mandatory)]
    [string]$Organization,
    [parameter(mandatory)]
    [string]$Platform,
    [parameter(mandatory)]
    [string]$Name,

    [string]$NavMiddleTier,
    [string]$SQLServer,

    [string]$LoginInfo,
    [string]$RDSServer
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

Update-SQLNAVCustomerConfig -Organization $Organization -Platform $Platform -Name $Name -NavMiddleTier $NavMiddleTier -SQLServer $SQLServer -LoginInfo $LoginInfo -RDSServer $RDSServer