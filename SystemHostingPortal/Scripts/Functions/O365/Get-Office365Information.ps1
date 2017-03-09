function New-Office365Billing {
    [Cmdletbinding()]
    param ()

    Begin {
    }
    Process {
        [pscustomobject]@{
            TenantID      = $null
            PartnerName   = $null
            Admin         = $null
            License       = $null
            ActiveUnits   = $null
            ConsumedUnits = $null
            FreeUnits     = $null
        }
    }
}

function Get-Office365Information {
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
   

    ## Trying to get ID and return id as an object.
    if($Config.Office365.TenantID -eq "null"){
        $ID = @()
        $newid = New-Office365Billing

        $newid.PartnerName   = "Not configured"
        $newid.TenantID      = 'null'
        $newid.Admin         = 'null'
        $newid.License       = "Not O365 enabled.."
        $newid.ActiveUnits   = 0
        $newid.ConsumedUnits = 0
        $newid.FreeUnits     = 0

        $ID += $newid
        #$ID += $newid

        return $ID
    }
    else{
        $ID = @()
        Connect-O365 -Organization $Organization
        $SKU = Get-MsolAccountSku
        foreach($i in $SKU){
            $newid = New-Office365Billing

            $newid.PartnerName   = Get-MsolPartnerInformation -TenantId $Config.Office365.TenantID | select -ExpandProperty PartnerCompanyName
            $newid.TenantID      = $Config.Office365.TenantID
            $newid.Admin         = $Config.Office365.AdminUser
            $newid.ActiveUnits   = $i.ActiveUnits
            $newid.ConsumedUnits = $i.ConsumedUnits
            $newid.FreeUnits     = ($i.ActiveUnits - $i.ConsumedUnits)

            switch($i) 
                { 
                    {($i.AccountSkuId -like "*ENTERPRISEPACK")}{$newid.License = "Office 365 E3"      }
                    {($i.AccountSkuId -like "*STANDARDPACK")}{$newid.License = "Office 365 E1"      }
                    {($i.AccountSkuId -like "*OFFICESUBSCRIPTION")}{$newid.License = "Office 365 ProPlus" }
                    {($i.AccountSkuId -like "*VISIOCLIENT")}{$newid.License = "Visio Pro til Office 365" }
                    {($i.AccountSkuId -like "*EXCHANGESTANDARD")}{$newid.License = "Exchange Online-plan 1" }
                    {($i.AccountSkuId -like "*PROJECTCLIENT")}{$newid.License = "Project Pro til Office 365" }
                    {($i.AccountSkuId -like "*WIN10_PRO_ENT_SUB")}{$newid.License = "Windows 10 Enterprise E3" }
                    {($i.AccountSkuId -like "*ATP_ENTERPRISE")}{$newid.License = "Advanced Threat Protection til Exchange Online" }
                    default {$newid.License = "License not known.." } 
                }

                $ID += ($newid)
            }

        return $ID
        }
    }
}

