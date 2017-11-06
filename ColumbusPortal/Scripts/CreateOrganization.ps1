[Cmdletbinding(DefaultParametersetName='None')]
param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$Initials,

    [Parameter(Mandatory)]
    [string]$Platform,

    [Parameter(Mandatory)]
    [string]$EmailDomainName,

    [bool]$CreateVMM,

    [string]$Subnet,
        
    [string]$Vlan,

    [string]$Gateway,
        
    [string]$IPAddressRangeStart,
        
    [string]$IPAddressRangeEnd,

    [bool]$createcrayon,

    [string]$InvoiceProfile,

    [string]$CrayonDomainPrefix,

    [string]$CrayonFirstName,

    [string]$CrayonLastName,

    [string]$CrayonEmail,

    [string]$CrayonPhoneNumber,

    [string]$CrayonCustomerFirstName,

    [string]$CrayonCustomerLastName,

    [string]$CrayonAddressLine1,

    [string]$CrayonCity,

    [string]$CrayonRegion,

    [string]$CrayonPostalCode
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$newOrgParams = @{
    Organization    = $Initials
    Platform        = $Platform
    Name            = $Name
    EmailDomainName = $EmailDomainName 
}

if($CreateVMM -eq $true){
    $newOrgParams.add("CreateVMM", $true)
    $newOrgParams.add("Subnet", $Subnet)
    $newOrgParams.add("Vlan", $Vlan)
    $newOrgParams.add("Gateway", $Gateway)
    $newOrgParams.add("IPAddressRangeStart", $IPAddressRangeStart)
    $newOrgParams.add("IPAddressRangeEnd", $IPAddressRangeEnd)
}
if($createcrayon -eq $true) {
    $newOrgParams.add("createcrayon", $true)
    $newOrgParams.add("InvoiceProfile", $InvoiceProfile)
    $newOrgParams.add("CrayonDomainPrefix", $CrayonDomainPrefix)
    $newOrgParams.add("CrayonFirstName", $CrayonFirstName)
    $newOrgParams.add("CrayonLastName", $CrayonLastName)
    $newOrgParams.add("CrayonEmail", $CrayonEmail)
    $newOrgParams.add("CrayonPhoneNumber", $CrayonPhoneNumber)
    $newOrgParams.add("CrayonCustomerFirstName", $CrayonCustomerFirstName)
    $newOrgParams.add("CrayonCustomerLastName", $CrayonCustomerLastName)
    $newOrgParams.add("CrayonAddressLine1", $CrayonAddressLine1)
    $newOrgParams.add("CrayonCity", $CrayonCity)
    $newOrgParams.add("CrayonRegion", $CrayonRegion)
    $newOrgParams.add("CrayonPostalCode", $CrayonPostalCode)
}

New-ENTOrganization @newOrgParams