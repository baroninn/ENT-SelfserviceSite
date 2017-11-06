[Cmdletbinding()]
param (
    [string]$Organization,
    [string]$RessourceGroupname
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Header = Get-AzureAPIToken -Organization $Organization

Get-AzureAPIAvailabilitySet -Header $Header -RessourceGroupname $RessourceGroupname