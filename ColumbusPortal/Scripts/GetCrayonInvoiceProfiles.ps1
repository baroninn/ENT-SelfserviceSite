[Cmdletbinding()]

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$Header = Get-CrayonAPIToken

Get-CrayonInvoiceProfiles -Header $Header

