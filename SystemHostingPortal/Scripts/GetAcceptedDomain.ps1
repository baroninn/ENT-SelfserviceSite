[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$Config = Get-ENTConfig -Organization $Organization -JSON

$accepteddomains = @()
    foreach($i in ($Config.EmailDomains.DomainName)) {
    $accepteddomains += 
        [pscustomobject]@{
            Organization      = $Organization
            DomainName        = $i
        }
    }

return $accepteddomains | sort DomainName
