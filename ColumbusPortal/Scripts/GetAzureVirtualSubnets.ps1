[Cmdletbinding()]
param (
    [string]$Organization,
    [string]$RessourceGroupname,
    [string]$Name
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Header = Get-AzureAPIToken -Organization $Organization

$vnet = Get-AzureAPIVirtualNetwork -Header $Header -RessourceGroupname $RessourceGroupname -Name $Name

$subnets = @()
foreach ($i in $vnet.properties.subnets) {
    $object = [pscustomobject]@{
        name = $i.name
        id = $i.id
        addressPrefix = $i.properties.addressPrefix
    }
    $subnets += $object
}
return $subnets