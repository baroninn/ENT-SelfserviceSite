function Get-TenantInformation {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TenantName
    )

    Begin {
    }
    
    Process {
    
    $ErrorActionPreference = "Stop"

    $Config = Get-TenantConfig -TenantName $TenantName

    $ID = [pscustomobject]@{
          Organization = $TenantName
          ID           = $null
          PartnerName  = $null
          Admin        = $null
          License      = $null
          }

    ## Trying to get ID and return id as an object.
    if($config.TenantID365.ID -eq $null){
        $ID.PartnerName = "Not configured"
        $ID.ID          = "Tenant not O365 enabled yet"
        $ID.Admin       = ''
        $ID.License     = ''
        return $ID
    }
    else{
        Connect-O365 -Organization $TenantName
        $SKU = (Get-MsolAccountSku).AccountSkuId
        $ID.PartnerName = Get-MsolPartnerInformation -TenantId $Config.TenantID365.ID | select -ExpandProperty PartnerCompanyName
        $ID.ID          = $config.TenantID365.ID
        $ID.Admin       = $Config.TenantID365.Admin

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
