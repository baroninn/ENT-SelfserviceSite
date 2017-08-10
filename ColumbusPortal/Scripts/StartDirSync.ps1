[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,
    [Parameter(Mandatory)]
    [ValidateSet("initial", "delta")]
    [string]$Policy
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$Config = Get-SQLEntConfig -Organization $Organization

if ($Config.AADsynced -eq 'true') {
    Start-DirSync -Organization $Organization -Policy $Policy
}
else {
    throw "Organization is not directory synced according to conf.."
}