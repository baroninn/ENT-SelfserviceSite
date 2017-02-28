[Cmdletbinding()]
param (
        [Parameter(Mandatory)]
        [string]$Organization,

        [Parameter(Mandatory)]
        [string]$EmailDomainName,

        [Parameter(Mandatory)]
        [string]$Subnet,

        [Parameter(Mandatory)]
        [string]$Vlan,
        
        [Parameter(Mandatory)]
        [string]$IPAddressRangeStart,

        [Parameter(Mandatory)]
        [string]$IPAddressRangeEnd
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

New-ENTOrganization -Organization $Organization -EmailDomainName $EmailDomainName -Subnet $Subnet -Vlan $Vlan -IPAddressRangeStart $IPAddressRangeStart -IPAddressRangeEnd $IPAddressRangeEnd
