function New-CrayonTenant {
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

        $Tenant = [pscustomobject]@{
            Name = $($Name)
            Publisher = [pscustomobject]@{
              Id = "2"   
	        }
            DomainPrefix = "$($DomainPrefix)"
            Reference =  "$($Reference)"
            CustomerTenantType = "2"
            Organization = [pscustomobject]@{
              Id = "6149"
            }
            InvoiceProfile = [pscustomobject]@{
              Id = "$($InvoiceProfile)"
            }
        }
        $Profile = [pscustomobject]@{
            Contact = [pscustomobject]@{
              FirstName = "$($FirstName)"
              LastName = "$($LastName)"
              Email = "$($Email)"
              PhoneNumber = "$($PhoneNumber)"
            }
            Address = [pscustomobject]@{
              FirstName = "$($CustomerFirstName)"
              LastName = "$($CustomerLastName)"
              AddressLine1 = "$($AddressLine1)"
              City = "$($City)"
              Region = "$($Region)"
              PostalCode = "$($PostalCode)"
              CountryCode = "DK"
            }
        }
        $object = [pscustomobject]@{
            Tenant = $Tenant
            Profile = $Profile
        }

        $newtenant = Invoke-RestMethod -Uri "https://api.crayon.com/api/v1/customertenants" -Method POST -Body ($object | ConvertTo-Json) -Headers $Header -ContentType 'application/json; charset=utf-8'

        $returnobject = [pscustomobject]@{
            Id = $newtenant.Tenant.Id
            Name = $newtenant.Tenant.Name
            PublisherCustomerId = $newtenant.Tenant.PublisherCustomerId
            ExternalPublisherCustomerId = $newtenant.Tenant.ExternalPublisherCustomerId
            DomainPrefix = $newtenant.Tenant.DomainPrefix
            Reference = $newtenant.Tenant.Reference
            AdminUser = $newtenant.User.UserName
            AdminPass = $newtenant.User.Password
        }
        return $returnobject
    }

}