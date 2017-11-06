[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,

    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$Location,

    [Parameter(Mandatory)]
    [string]$RessourceGroupName,

    [Parameter(Mandatory)]
    [string]$StorageAccount,

    [Parameter(Mandatory)]
    [string]$VirtualNetwork,
    [Parameter(Mandatory)]

    [string]$NetworkInterface,

    [Parameter(Mandatory)]
    [string]$Subnet,

    [Parameter(Mandatory)]
    [string]$PublicIP,

    [Parameter(Mandatory)]
    [string]$AvailabilitySet,

    [Parameter(Mandatory)]
    [string]$VMSize
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$params = @{
    Organization = $Organization
    Name = $Name
    Location = $Location
    RessourceGroupName = $RessourceGroupName
    StorageAccount = $StorageAccount
    VirtualNetwork = $VirtualNetwork
    NetworkInterface = $NetworkInterface
    Subnet = $Subnet
    PublicIP = $PublicIP
    AvailabilitySet = $AvailabilitySet
    VMSize = $VMSize
}

New-AzureAPIVM @params