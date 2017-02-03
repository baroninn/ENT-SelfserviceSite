function Get-TenantID {
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
        Connect-O365 -Organization $TenantName -command Get-Mailbox
        $SKU = (Get-MsolAccountSku).AccountSkuId
        $ID.PartnerName = Get-MsolPartnerInformation -TenantId $config.TenantID365.ID | select -ExpandProperty PartnerCompanyName
        $ID.ID          = $config.TenantID365.ID
        $ID.Admin       = $Config.TenantID365.Admin
            if($SKU -like "*ENTERPRISEPACK"){$ID.License         = "Office 365 E3"     } #Return $sku if you want real name and more than one license
            elseif($SKU -like "*OFFICESUBSCRIPTION"){$ID.License = "Office 365 ProPlus"} #Return $sku if you want real name and more than one license
            
            else{$ID.License = "Not known"}

        return $ID
        }
    }
}
