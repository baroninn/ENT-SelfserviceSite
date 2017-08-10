[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]$UserPrincipalName,

    [Parameter(Mandatory)]
    [string[]]
    $EmailAddresses,

    [bool]
    $SetFirstAsPrimary
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

foreach ($alias in $EmailAddresses) {
    if ($SetFirstAsPrimary) {
        Add-EmailAddress -Organization $Organization -Name $UserPrincipalName -EmailAddress $alias -SetAsPrimary $true
    }
    else {
        Add-EmailAddress -Organization $Organization -Name $UserPrincipalName -EmailAddress $alias
    }

    $SetFirstAsPrimary = $false
}