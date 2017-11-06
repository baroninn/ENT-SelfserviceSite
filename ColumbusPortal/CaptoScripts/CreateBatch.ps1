[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [PSObject[]]
    $UserList
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

$UserList | New-TenantUser