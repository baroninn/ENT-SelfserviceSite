[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,

    [string]$UserPrincipalName
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

if ($UserPrincipalName) {
Get-ADUserlist -Organization $Organization -UserPrincipalName $UserPrincipalName
}
else {
Get-ADUserlist -Organization $Organization
}