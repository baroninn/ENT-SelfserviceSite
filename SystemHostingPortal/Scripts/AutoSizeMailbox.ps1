[Cmdletbinding()]
param (
    
)

$ErrorActionPreference = "Continue"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

$VerbosePreference = 'Continue'

Get-Tenant | where TenantName -notmatch "T\d{2,3}" | Get-TenantMailbox | Set-TenantMailboxPlan -AutoSize