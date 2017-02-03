[Cmdletbinding()]
param(
    [Parameter(Mandatory)]
    [string]
    $Organization
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot Capto)

$Config = Get-TenantConfig -TenantName $Organization
 
$O365Info = Get-TenantID -TenantName $Organization

$stats = [pscustomobject]@{

            Office365 = [pscustomobject]@{
                Info = @()
            }
}

$365stats = New-Office365BillingObject

$365stats.Admin       = $O365Info.Admin
$365stats.License     = $O365Info.License
$365stats.TenantID    = $O365Info.ID
$365stats.PartnerName = $O365Info.PartnerName

return $365stats