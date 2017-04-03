[Cmdletbinding()]

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

Import-Module virtualmachinemanager | Out-Null
Get-SCVirtualMachine -VMMServer vmm-a.corp.systemhosting.dk #| where{$_.Cloud -notlike $null -xor $_.Cloud -notlike "backbone" -xor $_.Cloud -notlike "Shared Platform" -xor $_.Cloud -notlike "IaaS" -xor $_.Cloud -notlike "CPO - Capto - Produktion"}
