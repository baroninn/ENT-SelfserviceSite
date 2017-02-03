[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

$Config = Get-Content ("C:\ENTScriptsTest\Config\$Organization.txt") -Raw | ConvertFrom-Json

$obj = $Config.EmailDomains.DomainName

$accepteddomains = @()
foreach($i in $obj) {
$accepteddomains += 
    [pscustomobject]@{
        Organization      = $Organization
        DomainName        = $i
    }
}

return $accepteddomains | sort DomainName