[Cmdletbinding()]
param (
    
)

$ErrorActionPreference = "Continue"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

$VerbosePreference = 'Continue'

$Mailbox = Get-Tenant | where TenantName -notmatch "T\d{2,3}" | Get-TenantMailbox

foreach ($i in $Mailbox) {

    try{
        Set-TenantMailboxPlan -TenantName $i.CustomAttribute1 -Name $i.UserPrincipalName -AutoSize
    }
    catch{Write-Error "Error: for $($i.UserPrincipalName) - $($_.Exception)"}
}