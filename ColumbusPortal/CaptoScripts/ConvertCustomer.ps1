[Cmdletbinding()]
param(
    [parameter(Mandatory=$true)]
    [string]$Organization,

    [switch]$Confirm
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

if (-not $Confirm) { throw "You haven't confirmed to convert the customer.. Are you really sure you wanna do this?!?" }

Import-Module (Join-Path $PSScriptRoot Capto)

$Config = Get-TenantConfig -TenantName $Organization

if ($Config.Product.Name -ne 'AdvoPlus') {
    throw "Error! not AdvoPlus customer.. What the hell are you doing?!?"
}

else {
   Convert-Customer -Organization $Organization
}