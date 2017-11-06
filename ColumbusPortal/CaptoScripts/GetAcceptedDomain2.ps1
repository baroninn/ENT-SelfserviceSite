[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

Get-TenantAcceptedDomain -TenantName $Organization | Sort Name | Select Name, DomainName