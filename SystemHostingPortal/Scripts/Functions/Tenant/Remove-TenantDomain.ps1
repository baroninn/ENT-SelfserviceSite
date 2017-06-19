function Remove-TenantDomain {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,

        [Parameter(Mandatory)]
        [string]$Domain,

        [switch]$RemoveasEmail
    )

    Begin {

    $ErrorActionPreference = "Stop"
    Import-Module ActiveDirectory

    $Config = Get-EntConfig -Organization $Organization -JSON
    $Cred  = Get-RemoteCredentials -Organization $Organization

    }

    Process {


        if ($Config.Office365.TenantID -ne "null" -and $RemoveasEmail) {
            Connect-O365 -Organization $Organization
            
            try {
                Remove-MsolDomain -DomainName $Domain -Force | Out-Null
            }
            catch {
                throw "Remove-MSOLDomain - Error: $_"
            }
        }

        if ($Config.ExchangeServer -ne "null") {
            
            Import-Module (New-ExchangeProxyModule -Organization $Organization -Command "Remove-AcceptedDomain")

            try {
                Remove-AcceptedDomain -Identity $Domain -Confirm:$false | Out-Null
            }
            catch {
                throw "Remove-AcceptedDomain - Error: $_"
            }
        }


        try {
            $Forest = Get-ADForest -Server $Config.DomainFQDN -Credential $Cred
            Set-ADForest -Identity $Forest -Server $Config.DomainFQDN -UPNSuffixes @{Remove=$Domain} -Credential $Cred | Out-Null
        }
        catch { 

            throw "Set-Adforest - Error: $_"
        }

        ## Update Config without the specified domain..
        try {
            ## Because object is of fixed size, we need to create a new array, and overwrite the sub-object..
            $NewDomains = @()
            foreach ($i in $Config.EmailDomains.DomainName) {
                if ($i -ne $Domain) {
                        $NewDomains += $i
                }
            }

            Set-EntConfig -Organization $Organization -Domains $NewDomains | Out-Null
        }
        catch {
            throw "Error updating config: $_"
        }

        Get-PSSession | Remove-PSSession
    }
}