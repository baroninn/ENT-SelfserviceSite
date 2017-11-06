[Cmdletbinding()]
param (
    [string]$Organization
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Header = Get-AzureAPIToken -Organization $Organization

Get-AzureAPIRessourceGroup -Header $Header