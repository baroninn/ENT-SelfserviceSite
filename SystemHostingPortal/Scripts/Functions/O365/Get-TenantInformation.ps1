function Get-TenantInformation {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization
    )

    Begin {
    }
    
    Process {
    
    $ErrorActionPreference = "Stop"

    $Config = Get-EntConfig -Organization $Organization -JSON

    $ID = [pscustomobject]@{
          Organization = $Organization
          ID           = $null
          PartnerName  = $null
          Admin        = $null
          License      = $null
          }

    ## Trying to get ID and return id as an object.
    if($Config.Office365.TenantID -eq "null"){
        $ID.PartnerName = "Not configured"
        $ID.ID          = "Tenant not O365 enabled yet"
        $ID.Admin       = ''
        $ID.License     = ''
        return $ID
    }
    else{
        Connect-O365 -Organization $Organization
        $SKU = (Get-MsolAccountSku).AccountSkuId
        $ID.PartnerName = Get-MsolPartnerInformation -TenantId $Config.Office365.TenantID | select -ExpandProperty PartnerCompanyName
        $ID.ID          = $Config.Office365.TenantID
        $ID.Admin       = $Config.Office365.AdminUser

        switch($SKU) 
            { 
                {($_ -like "*ENTERPRISEPACK")}{$ID.License = "Office 365 E3"      }
                {($_ -like "*STANDARDPACK")}{$ID.License = "Office 365 E1"      }
                {($_ -like "*OFFICESUBSCRIPTION")}{$ID.License = "Office 365 ProPlus" }
                default {$ID.License = "License not known.." } 
            }

        return $ID
        }
    }
}
