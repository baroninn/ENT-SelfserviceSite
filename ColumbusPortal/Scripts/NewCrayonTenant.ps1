[Cmdletbinding()]
param(
    [Parameter(Mandatory)]
    [string]$Orginaztion,   

    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$DomainPrefix,

    [Parameter(Mandatory)]
    [string]$Reference,

    [Parameter(Mandatory)]
    [string]$InvoiceProfile,

    [Parameter(Mandatory)]
    [string]$FirstName,

    [Parameter(Mandatory)]
    [string]$LastName,

    [Parameter(Mandatory)]
    [string]$Email,

    [Parameter(Mandatory)]
    [string]$PhoneNumber,

    [Parameter(Mandatory)]
    [string]$CustomerFirstName,

    [Parameter(Mandatory)]
    [string]$CustomerLastName,

    [Parameter(Mandatory)]
    [string]$AddressLine1,

    [Parameter(Mandatory)]
    [string]$City,

    [Parameter(Mandatory)]
    [string]$Region,

    [Parameter(Mandatory)]
    [string]$PostalCode
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)

$Header = Get-CrayonAPIToken

New-CrayonTenant -Header $Header `
                 -Name $Name `
                 -Reference $Reference `
                 -DomainPrefix $DomainPrefix `
                 -FirstName $FirstName `
                 -LastName $LastName `
                 -Email $Email `
                 -PhoneNumber $PhoneNumber `
                 -CustomerFirstName $CustomerFirstName `
                 -CustomerLastName $CustomerLastName `
                 -InvoiceProfile $InvoiceProfile `
                 -AddressLine1 $AddressLine1 `
                 -City $City `
                 -Region $Region `
                 -PostalCode $PostalCode