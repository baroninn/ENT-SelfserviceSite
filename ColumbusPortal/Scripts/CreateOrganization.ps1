[Cmdletbinding()]
param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$Initials,

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
    New-ENTOrganization -Organization $Initials -Name $Name -EmailDomainName $EmailDomainName -Subnet $Subnet -Vlan $Vlan -Gateway $Gateway -IPAddressRangeStart $IPAddressRangeStart -IPAddressRangeEnd $IPAddressRangeEnd -CreateVMM
}
else {
    New-ENTOrganization -Organization $Initials -Name $Name -EmailDomainName $EmailDomainName
}

