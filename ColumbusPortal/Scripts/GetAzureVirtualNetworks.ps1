[Cmdletbinding()]
param (
    [string]$Organization,
    [string]$RessourceGroupname
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Header = Get-AzureAPIToken -Organization $Organization

Get-AzureAPIVirtualNetwork -Header $Header -RessourceGroupname $RessourceGroupname