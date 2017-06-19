[Cmdletbinding()]
param(
    [Parameter(Mandatory)]
    [string]$Organization,

    [Parameter(Mandatory)]
    [string]$EmailDomainName,

    [string]$Subnet,

    [string]$Vlan,

    [string]$Gateway,
        
    [string]$IPAddressRangeStart,

    [string]$IPAddressRangeEnd,

    [bool]$CreateVMM
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

if($CreateVMM){
    New-ENTOrganization -Organization $Organization -EmailDomainName $EmailDomainName -Subnet $Subnet -Vlan $Vlan -Gateway $Gateway -IPAddressRangeStart $IPAddressRangeStart -IPAddressRangeEnd $IPAddressRangeEnd -CreateVMM
}
else {
    New-ENTOrganization -Organization $Organization -EmailDomainName $EmailDomainName
}

