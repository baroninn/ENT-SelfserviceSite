function Set-CrayonTenant {
    <#
    .SYNOPSIS
        Create a new tenant in Crayon Portal


    .EXAMPLE
        New-CrayonTenant <all params>

    .NOTES
    Author:      Jakob Strøm
    Contact:     jst@columbusglobal.com
    Created:     2017-10-11
    #>
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [hashtable]$Header,
        [Parameter(Mandatory)]
        [string]$Id,
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

    Begin {

        $ErrorActionPreference = "Stop"

    }
    
    Process {
        $Id = '16700'
        $tenant = Invoke-RestMethod -Uri "https://api.crayon.com/api/v1/customertenants/$($Id)/detailed/" -Method GET -Headers $Header
        $tenant.Profile.Address.FirstName = "$FirstName"
        $tenant.Profile.Address.LastName = "$LastName"
        $tenant.Profile.Address.AddressLine1 = "$AddressLine1"
        $tenant.Profile.Address.City = "$City"
        $tenant.Profile.Address.Region = "$Region"
        $tenant.Profile.Address.PostalCode = "$PostalCode"

        $update = Invoke-RestMethod -Uri "https://api.crayon.com/api/v1/customertenants/$($Id)/" -Method PUT -Body ($Tenant | ConvertTo-Json) -Headers $Header -ContentType 'application/json; charset=utf-8'
        

        $newtenant = Invoke-RestMethod -Uri "https://api.crayon.com/api/v1/customertenants" -Method POST -Body ($object | ConvertTo-Json) -Headers $Header -ContentType 'application/json; charset=utf-8'
    }

}