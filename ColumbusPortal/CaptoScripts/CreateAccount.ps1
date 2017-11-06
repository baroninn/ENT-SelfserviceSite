[Cmdletbinding()]
param(
    [parameter(Mandatory=$true)]
    [string]$Organization,

    [string]$AccountName,

    [Parameter(Mandatory)]
    [string]$Shortname
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

New-TenantAccount -Organization $Organization -AccountName $AccountName -Shortname $Shortname