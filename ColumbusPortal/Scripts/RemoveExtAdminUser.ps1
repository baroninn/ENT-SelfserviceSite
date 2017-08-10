[cmdletbinding()]
param(
    [parameter(mandatory)]
    [string]$Organization,
    [parameter(mandatory)]
    [string]$ID
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

Remove-EXTAdminUser -Organization $Organization -ID $ID