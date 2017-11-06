[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [bool]
    $ExcludeFromAutoSize
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

if ($ExcludeFromAutoSize) {
    Get-Tenant -Name $Organization | Get-TenantMailbox | Set-TenantUser -ExcludeFromMailboxAutoResize $true
}
else {
    Get-Tenant -Name $Organization | Get-TenantMailbox | Set-TenantUser -ExcludeFromMailboxAutoResize $false
}

