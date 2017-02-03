function New-Office365LicenseObject {
    [Cmdletbinding()]
    param ()

    Begin {
    }
    Process {
        [pscustomobject]@{
            AccountSkuId       = $null
            ActiveUnits        = $null
            ConsumedUnits      = $null
        }
    }
}

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
          License      = @()
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
        $SKU = Get-MsolAccountSku
        $info = New-Office365LicenseObject

        $ID.PartnerName = Get-MsolPartnerInformation -TenantId $config.TenantID365.ID | select -ExpandProperty PartnerCompanyName
        $ID.ID          = $config.TenantID365.ID
        $ID.Admin       = $Config.TenantID365.Admin
            if($SKU.AccountSkuId -like "*ENTERPRISEPACK"){
                $info.AccountSkuId  = "Office 365 E3"     
                $info.ActiveUnits   = $SKU.ActiveUnits
                $info.ConsumedUnits = $SKU.ConsumedUnits
                $ID.License += ($info)} #Return $sku if you want real name and more than one license


            elseif($SKU.AccountSkuId -like "*OFFICESUBSCRIPTION"){
                    $info.AccountSkuId  = "Office 365 ProPlus"     
                    $info.ActiveUnits   = $SKU.ActiveUnits
                    $info.ConsumedUnits = $SKU.ConsumedUnits
                    $ID.License += ($info)} #Return $sku if you want real name and more than one license
            
            else{$ID.License = "Not known"}

        return $ID
        }
    }
}
