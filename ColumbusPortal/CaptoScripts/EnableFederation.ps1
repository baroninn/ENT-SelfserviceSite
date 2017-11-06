[Cmdletbinding()]
param (
        [Parameter(Mandatory)]
        [string]$Organization,
        [Parameter(Mandatory)]
        [string]$Domain
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

Enable-Federation -TenantName $Organization -Domain $Domain