[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Solution,

    [switch]$MCSEnabled
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

if ($MCSEnabled) {
Get-CTXGoldenServers -Solution $Solution -MCSEnabled
}
else {
Get-CTXGoldenServers -Solution $Solution
}