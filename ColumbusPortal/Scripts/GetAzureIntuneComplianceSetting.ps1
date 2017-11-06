[Cmdletbinding()]
param (
    [string]$Organization,
    [string]$ID
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Header = Get-AzureAPIToken -Organization $Organization -GraphAPI

if ($ID -ne $null) {
    Get-AzureIntuneComplianceSetting -Header $Header -ID $ID
}
else {
    Get-AzureIntuneComplianceSetting -Header $Header
}