[Cmdletbinding()]
param(
    [parameter(Mandatory=$true)]
    [string]$ID
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

Get-VMInfo -VMID $ID