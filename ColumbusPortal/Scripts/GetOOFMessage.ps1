[Cmdletbinding()]
param (
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [string]$Organization,

    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string]$UserPrincipalName
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot Functions)

$params = @{
    Organization         = $Organization
    UserPrincipalName    = $UserPrincipalName
}

Get-MailboxOOFMessage @params