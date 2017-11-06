[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [ValidateSet("AdvoPlus", "Legal", "Member2015")]
    [string]$Solution,
    [string]$VMName,
    [switch]$Test

)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot "Capto")


Update-MCSImage -Solution $Solution -VMName $VMName
