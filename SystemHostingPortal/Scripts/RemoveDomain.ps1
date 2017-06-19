[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,

    [Parameter(Mandatory)]
    [string]$Domain,

    [switch]$RemoveasEmail
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

if ($RemoveasEmail) {
    Remove-TenantDomain -Organization $Organization -Domain $Domain -RemoveasEmail
}
else {
    Remove-TenantDomain -Organization $Organization -Domain $Domain
}