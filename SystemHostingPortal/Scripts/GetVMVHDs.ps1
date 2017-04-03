[Cmdletbinding()]
param(
    #[parameter(Mandatory=$true)]
    [string]$VHDID
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

Get-VMVHD -VMID $VHDID