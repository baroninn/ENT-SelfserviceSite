[Cmdletbinding()]
param (
    [parameter(mandatory)]
    [string]$Organization
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

Remove-SQLSharedCustomerConfig -Organization $Organization