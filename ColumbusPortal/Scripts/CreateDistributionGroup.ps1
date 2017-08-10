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
    $UserName,

    [Parameter(Mandatory)]
    [string]
    $DomainName,

    [string]
    $ManagedBy,

    [switch]
    $RequireSenderAuthentication
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$PrimarySmtpAddress = ($UserName + '@' + $DomainName)

if ($RequireSenderAuthentication) {
    New-TenantDistributionGroup -Organization $Organization -Name $Name -PrimarySmtpAddress $PrimarySmtpAddress -ManagedBy $ManagedBy -RequireSenderAuthentication
}
else {
    New-TenantDistributionGroup -Organization $Organization -Name $Name -PrimarySmtpAddress $PrimarySmtpAddress -ManagedBy $ManagedBy
}