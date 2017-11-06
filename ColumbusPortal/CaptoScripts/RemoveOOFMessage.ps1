[Cmdletbinding()]
param (
    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [string]$Organization,

    [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
    [ValidateNotNullOrEmpty()]
    [string]$UserPrincipalName
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2.0

Import-Module (Join-Path $PSScriptRoot Capto)

$params = @{
    Organization         = $Organization
    UserPrincipalName    = $UserPrincipalName
}

Remove-MailboxOOFMessage @params