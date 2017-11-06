[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]
    $UserPrincipalName,

    [Parameter(Mandatory)]
    [string[]]
    $EmailAddresses
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

foreach ($alias in $EmailAddresses) {
    Remove-EmailAddress -TenantName $Organization -Name $UserPrincipalName -EmailAddress $alias
}