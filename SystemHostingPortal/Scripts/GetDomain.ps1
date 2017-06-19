[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,

    [switch]$O365
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$Config = Get-ENTConfig -Organization $Organization -JSON

$domains = @()

if ($O365) { 
    if ($Config.Office365.TenantID -ne "null") {

        Connect-O365 -Organization $Organization
    
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
        Write-Verbose "Missing tenant info in conf.."
    }
}
else {

    foreach($i in ($Config.EmailDomains.DomainName)) {
    $domains += 
        [pscustomobject]@{
            Organization      = $Organization
            DomainName        = $i
        }
    }
}

return $domains | sort DomainName
