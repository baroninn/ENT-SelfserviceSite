[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,

    [Parameter(Mandatory)]
    [ValidateSet('Auto', 'Max')]
    [string]$MailboxPlan
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Capto)

if ($MailboxPlan -eq 'Auto') {
    Get-TenantMailbox -TenantName $Organization | Set-TenantMailboxPlan -AutoSize
}
else {
    Get-TenantMailbox -TenantName $Organization | Set-TenantMailboxPlan -MailboxPlan 50GB
}