[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,

    [switch]$O365
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$Config = Get-SQLENTConfig -Organization $Organization

$domains = @()

if ($O365) { 
    if ($Config.TenantID) {

        Connect-MSOnline -Organization $Organization
    
        $Dom = ((Get-MsolDomain)| where{$_.Name -notlike "*onmicrosoft.com"})

        foreach ($i in $Dom) {
            $domains += 
            [pscustomobject]@{
                DomainName = $i.Name
                Status     = $i.Status
                IsDefault  = $i.IsDefault
            }
        }

    }
    else {
        Write-Verbose "Customer doesn't seem to have Office 365 enabled in conf.."
    }
}
else {

    foreach($i in ($Config.EmailDomains -split ',')) {
    $domains += 
        [pscustomobject]@{
            Organization      = $Organization
            DomainName        = $i
        }
    }
}

return $domains | sort DomainName
