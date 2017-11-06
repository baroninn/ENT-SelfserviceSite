[Cmdletbinding()]
param (
    [string]$Organization,
    [string]$Location
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2
Import-Module (Join-Path $PSScriptRoot "Functions")

$Header = Get-AzureAPIToken -Organization $Organization

$IP = (Get-AzureAPIPublicIP -Header $header | where{$_.location -eq "$Location"})# | where{$_.properties.ipConfiguration -eq $null}

$PublicIPs = @()

foreach ($i in $IP) {
    if ($i.properties -match "ipConfiguration") {
        continue
    }
    else {
        $object = [pscustomobject]@{
            name = $i.name
            id = $i.id
            location = $i.location
            version = $i.properties.publicIPAddressVersion
            allocationMethod = $i.properties.publicIPAllocationMethod
            idleTimeoutInMinutes = $i.properties.idleTimeoutInMinutes

        }
        $PublicIPs += $object
    }
}
return $PublicIPs