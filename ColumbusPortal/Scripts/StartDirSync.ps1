[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,
    [Parameter(Mandatory)]
    [ValidateSet("initial", "delta")]
    [string]$Policy,

    [bool]$Force
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$Config = Get-SQLEntConfig -Organization $Organization

if ($Config.AADsynced -eq 'true') {
    if ($Force) {
        Start-DirSync -Organization $Organization -Policy $Policy -Force
    }
    else {
        Start-DirSync -Organization $Organization -Policy $Policy
    }
}
else {
    throw "Organization is not directory synced according to conf.."
}