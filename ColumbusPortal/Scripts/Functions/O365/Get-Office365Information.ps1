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

    $Config = Get-SQLEntConfig -Organization $Organization
   

    ## Trying to get ID and return id as an object.
    if($Config.TenantID -like $null){
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

            $newid.PartnerName   = Get-MsolPartnerInformation -TenantId $Config.TenantID | select -ExpandProperty PartnerCompanyName
            $newid.TenantID      = $Config.TenantID
            $newid.Admin         = $Config.AdminUser
            $newid.ActiveUnits   = $i.ActiveUnits
            $newid.ConsumedUnits = $i.ConsumedUnits
            $newid.FreeUnits     = ($i.ActiveUnits - $i.ConsumedUnits)

            if ($i.ActiveUnits -eq 10000 -and $i.AccountSkuId -like "*POWERAPPS_VIRAL") {
                $newid.License = "Microsoft Power Apps & Flow TRIAL"
            }
            else
            {

                switch($i) 
                    { 
                        {($i.AccountSkuId -like "*ENTERPRISEPACK")}{$newid.License = "O365 Enterprise E3"      }
                        {($i.AccountSkuId -like "*STANDARDPACK")}{$newid.License = "O365 Enterprise E1"      }
                        {($i.AccountSkuId -like "*OFFICESUBSCRIPTION")}{$newid.License = "O365 ProPlus" }
                        {($i.AccountSkuId -like "*VISIOCLIENT")}{$newid.License = "Visio Pro for O365" }
                        {($i.AccountSkuId -like "*EXCHANGESTANDARD")}{$newid.License = "Exchange Online (Plan 1)" }
                        {($i.AccountSkuId -like "*PROJECTCLIENT")}{$newid.License = "Project Pro for O365" }
                        {($i.AccountSkuId -like "*WIN10_PRO_ENT_SUB")}{$newid.License = "Windows 10 Enterprise E3" }
                        {($i.AccountSkuId -like "*ATP_ENTERPRISE")}{$newid.License = "ATP til Exchange Online" }
                        {($i.AccountSkuId -like "*AAD_BASIC")}{$newid.License = "Azure Active Directory Basic"      }
                        {($i.AccountSkuId -like "*AAD_PREMIUM")}{$newid.License = "Azure Active Directory Premium"      }
                        {($i.AccountSkuId -like "*RIGHTSMANAGEMENT")}{$newid.License = "Azure Rights Management Premium" }
                        {($i.AccountSkuId -like "*LOCKBOX")}{$newid.License = "Customer Lockbox" }
                        {($i.AccountSkuId -like "*EXCHANGE_ANALYTICS")}{$newid.License = "Delve Analytics" }
                        {($i.AccountSkuId -like "*EMS")}{$newid.License = "Enterprise Mobility Suite" }
                        {($i.AccountSkuId -like "*EXCHANGEENTERPRISE")}{$newid.License = "Exchange Online (Plan 2)" }
                        {($i.AccountSkuId -like "*EXCHANGEARCHIVE_ADDON")}{$newid.License = "EOA for Exchange Online" }
                        {($i.AccountSkuId -like "*EXCHANGEARCHIVE")}{$newid.License = "EOA for Exchange Server"      }
                        {($i.AccountSkuId -like "*EXCHANGEDESKLESS")}{$newid.License = "Exchange Online Kiosk"      }
                        {($i.AccountSkuId -like "*EOP_ENTERPRISE")}{$newid.License = "Exchange Online Protection" }
                        {($i.AccountSkuId -like "*INTUNE_A")}{$newid.License = "Intune" }
                        {($i.AccountSkuId -like "*INTUNE_STORAGE")}{$newid.License = "Intune Extra Storage" }
                        {($i.AccountSkuId -like "*ADALLOM_STANDALONE")}{$newid.License = "Cloud App Security" }
                        {($i.AccountSkuId -like "*EQUIVIO_ANALYTICS")}{$newid.License = "O365 Advanced eDiscovery" }
                        {($i.AccountSkuId -like "*O365_BUSINESS")}{$newid.License = "O365 Business" }
                        {($i.AccountSkuId -like "*O365_BUSINESS_ESSENTIALS")}{$newid.License = "O365 Business Essentials"      }
                        {($i.AccountSkuId -like "*O365_BUSINESS_PREMIUM")}{$newid.License = "O365 Business Premium"      }
                        {($i.AccountSkuId -like "*STANDARDWOFFPACK")}{$newid.License = "O365 Enterprise E2 (Nonprofit E1)" }
                        {($i.AccountSkuId -like "*ENTERPRISEWITHSCAL")}{$newid.License = "O365 Enterprise E4" }
                        {($i.AccountSkuId -like "*ENTERPRISEPREMIUM")}{$newid.License = "O365 Enterprise E5" }
                        {($i.AccountSkuId -like "*ENTERPRISEPREMIUM_NOPSTNCONF")}{$newid.License = "O365 Enterprise E5 w/o PSTN Conf" }
                        {($i.AccountSkuId -like "*DESKLESSPACK")}{$newid.License = "O365 Enterprise K1" }
                        {($i.AccountSkuId -like "*SHAREPOINTSTORAGE")}{$newid.License = "O365 Extra File Storage" }
                        {($i.AccountSkuId -like "*WACONEDRIVESTANDARD")}{$newid.License = "OneDrive for Business (Plan 1)" }
                        {($i.AccountSkuId -like "*WACONEDRIVEENTERPRISE")}{$newid.License = "OneDrive for Business (Plan 2)" }
                        {($i.AccountSkuId -like "*POWER_BI_STANDARD")}{$newid.License = "Power BI (free)"      }
                        {($i.AccountSkuId -like "*POWER_BI_PRO")}{$newid.License = "Power BI (Pro)"      }
                        {($i.AccountSkuId -like "*PROJECTESSENTIALS")}{$newid.License = "Project Lite" }
                        {($i.AccountSkuId -like "*PROJECTONLINE_PLAN_1")}{$newid.License = "Project Online" }
                        {($i.AccountSkuId -like "*SHAREPOINTSTANDARD")}{$newid.License = "SharePoint Online (Plan 1)" }
                        {($i.AccountSkuId -like "*SHAREPOINTENTERPRISE")}{$newid.License = "SharePoint Online (Plan 2)" }
                        {($i.AccountSkuId -like "*MCOEV")}{$newid.License = "SfB Cloud PBX" }
                        {($i.AccountSkuId -like "*MCOIMP")}{$newid.License = "SfB Online (Plan 1)" }
                        {($i.AccountSkuId -like "*MCOSTANDARD")}{$newid.License = "SfB Online (Plan 2)" }
                        {($i.AccountSkuId -like "*MCOMEETADV")}{$newid.License = "SfB PSTN Conferencing" }
                        {($i.AccountSkuId -like "*MCOPLUSCAL")}{$newid.License = "SfB Plus CAL"      }
                        {($i.AccountSkuId -like "*MCOPSTN1")}{$newid.License = "SfB PSTN Dom. Calling"      }
                        {($i.AccountSkuId -like "*MCOPSTN2")}{$newid.License = "SfB PSTN Dom. and Int. Calling" }
                        {($i.AccountSkuId -like "*CRMIUR")}{$newid.License = "Dynamics CRM Online Pro IUR" }
                        {($i.AccountSkuId -like "*YAMMER_ENTERPRISE_STANDALONE")}{$newid.License = "Yammer Enterprise" }
                        {($i.AccountSkuId -like "*LITEPACK")}{$newid.License = "O365 Small Business" }
                        {($i.AccountSkuId -like "*LITEPACK_P2")}{$newid.License = "O365 Small Business Premium" }
                        {($i.AccountSkuId -like "*CRMPLAN1")}{$newid.License = "Dynamics CRM Online Essential" }
                        {($i.AccountSkuId -like "*CRMPLAN2")}{$newid.License = "Dynamics CRM Online Basic" }
                        {($i.AccountSkuId -like "*CRMSTANDARD")}{$newid.License = "Dynamics CRM Online Pro" }
                        {($i.AccountSkuId -like "*POWERAPPS_VIRAL")}{$newid.License = "Microsoft Power Apps & Flow" }
                    

                        default {$newid.License = "License not known.." } 
                    }
                }

                $ID += ($newid)
            }

        return $ID
        }
    }
}

