[Cmdletbinding()]
param (

    [string]$Solution,
    [switch]$Test

)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot "Capto")

if ($Test) {
    New-GoldenVM -Solution $Solution -Test
}
if (-not $Test) {
    New-GoldenVM -Solution $Solution
}