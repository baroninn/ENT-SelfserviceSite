[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,

    [string]$Name
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$params = @{
    Organization = $Organization
}
if ($Name) {
    $params.Add("Name", ($name -split '@')[0])
}

Get-TenantMailbox @params | Sort RecipientTypeDetails,Name | Select Name, UserPrincipalName, RecipientTypeDetails, EmailAddresses
