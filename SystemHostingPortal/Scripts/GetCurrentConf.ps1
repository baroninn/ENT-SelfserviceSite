[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,
    [switch]$JSON
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

if (-not $JSON) {Get-ENTConfig -Organization $Organization}

else {Get-ENTConfig -Organization $Organization -JSON}