[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]
    $Name,

    [Parameter(Mandatory)]
    [string]
    $PrimarySmtpAddress,

    [Parameter(Mandatory)]
    [string]
    $ManagedBy,

    [bool]
    $RequireSenderAuthentication=$true
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

New-TenantDistributionGroup -TenantName $Organization -Name $Name -PrimarySmtpAddress $PrimarySmtpAddress -ManagedBy $ManagedBy -RequireSenderAuthentication $RequireSenderAuthentication