[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,

    [string]$Name
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

$params = @{
    TenantName = $Organization
}
if ($Name) {
    $params.Add("Name", $Name)
}

Get-TenantMailbox @params | Sort RecipientTypeDetails,Name | Select Name, UserPrincipalName, RecipientTypeDetails, EmailAddresses
