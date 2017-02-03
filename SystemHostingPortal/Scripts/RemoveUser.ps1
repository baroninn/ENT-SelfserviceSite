param(
    [parameter(Mandatory=$true)]
    $Organization,
    [parameter(Mandatory=$true)]
    $UserPrincipalName,

    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

$mbx = Get-TenantMailbox -TenantName $Organization -Name $UserPrincipalName -Single

$mbx | Remove-TenantUser -Force