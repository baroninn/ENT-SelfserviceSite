[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [ValidateSet("AdvoPlus", "Legal", "Member2015")]
    [string]$Solution,

    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$VMName,

    [Parameter(Mandatory)]
    [string]$OU,

    [Parameter(Mandatory)]
    [string]$NamingScheme

)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot "Capto")


New-MCSCatalog -Solution $Solution -Name $Name -VMName $VMName -OU $OU -NamingScheme $NamingScheme