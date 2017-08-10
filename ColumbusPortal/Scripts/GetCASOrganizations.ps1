[Cmdletbinding()]
param (
    [string]$Organization
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

Get-CASOrganizations -Type Shared