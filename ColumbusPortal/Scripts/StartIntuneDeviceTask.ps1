[Cmdletbinding()]
param (
    [parameter(mandatory)]
    [string]$Organization,
    [parameter(mandatory)]
    [string]$Task,
    [parameter(mandatory)]
    [string]$Id,

    [string]$Message,
    [string]$phoneNumber,
    [string]$footer
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$Header = Get-AzureAPIToken -Organization $Organization -GraphAPI

if ($Task -eq "enableLostMode") {
    Start-IntuneDeviceTask -Header $Header -Organization $Organization -Task $Task -Id $Id -message $Message -phoneNumber $phoneNumber -Footer $footer
}
else {
    Start-IntuneDeviceTask -Header $Header -Organization $Organization -Task $Task -Id $Id
}