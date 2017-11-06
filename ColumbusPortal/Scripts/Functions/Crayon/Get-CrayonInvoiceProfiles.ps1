function Get-CrayonInvoiceProfiles {
    <#
    .SYNOPSIS
        Gets the onvoice profiles available to our tenant


    .EXAMPLE
        Get-CrayonInvoiceProfiles

    .NOTES
    Author:      Jakob Strøm
    Contact:     jst@columbusglobal.com
    Created:     2017-10-12
    #>
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [hashtable]$Header 
    )

    Begin {

        $ErrorActionPreference = "Stop"
        $returnobject = @()
    }
    
    Process {
        
        $InvoiceProfiles = Invoke-RestMethod -Uri "https://api.crayon.com/api/v1/invoiceprofiles/?organizationId=6149" -Method GET -Headers $Header -ContentType 'application/json'

        foreach ($i in $InvoiceProfiles.Items) {
            $returnobject += [pscustomobject]@{
                Id = $i.Id
                Name = $i.Name
            }
        }
        return $returnobject
    }
}
