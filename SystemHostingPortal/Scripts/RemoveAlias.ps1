[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]$UserPrincipalName,

    [Parameter(Mandatory)]
    [string]
    $EmailAddresses
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

foreach ($alias in $EmailAddresses) {

    Remove-EmailAddress -Organization $Organization -Name $UserPrincipalName -EmailAddress $alias
}
