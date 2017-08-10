function Add-TenantDomain {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,

        [Parameter(Mandatory)]
        [string]$Domain,

        [switch]$AddasEmail
    )

    Begin {

    $ErrorActionPreference = "Stop"
    Import-Module ActiveDirectory

    $Config = Get-SQLEntConfig -Organization $Organization
    $Cred  = Get-RemoteCredentials -Organization $Organization

    }

    Process {

        if ($AddasEmail) {

            if ($Config.ExchangeServer -ne "null") {
                    
                Import-Module (New-ExchangeProxyModule -Organization $Organization -Command 'New-AcceptedDomain', 'Get-AcceptedDomain')

                try {
                    $accepteddomains = Get-AcceptedDomain | select -ExpandProperty DomainName
                    if ($accepteddomains -match $Domain) {
                        Write-Output "$Domain already exist in Exchange.. Not gonna do anything here.."
                    }
                    else {
                        New-AcceptedDomain -Name $Domain -DomainName $Domain -DomainType Authoritative
                    }
                }
                catch {
                    throw "ERROR: $_"
                }
            }

            else {
                if ($Config.Office365.TenantID -ne "null") {

                    Connect-O365 -Organization $Organization
            
                    try {
                        $MSOLDomains = Get-MsolDomain |select -ExpandProperty Name
                        if ($MSOLDomains -match $Domain) {
                            Write-Output "$Domain already exist in Office365.. Not gonna do anything here.."
                        }
                        else {
                            New-MsolDomain -Name $Domain | Out-Null

                            try {
                                $DNS = (Get-MsolDomainVerificationDns -DomainName $Domain).Label.split('.')[0]
                                Write-Output "Please create this TXT record in the DNS zone: MS=$DNS"
                            }
                            catch {
                                throw "Error getting verification DNS in O365 : $_"
                            }                            
                        }
                    }
                    catch {
                        throw "New-MSOLDomain - Error: $_"
                    }
                }
                else {
                    Write-Output "The customer conf doesn't have Exchange or Office365.. Domain will be added to Active Directory only!"
                }
            }
        }
                

        try {

            $Forest = Get-ADForest -Server $Config.DomainFQDN -Credential $Cred

            if ($Forest.UPNSuffixes.ValueList -match $Domain) {
                Write-Output "$Domain already exist in forest.. Not gonna do anything here.."
            }
            else {
                Set-ADForest -Identity $Forest -Server $Config.DomainFQDN -UPNSuffixes @{Add=$Domain} -Credential $Cred
            }

        }
        catch { 

            throw "Set-Adforest - Error: $_"
        }

        ## Update Config with new domain..
        try {

            if (($Config.EmailDomains -split ',') -match $Domain) {
                Write-Output "$Domain already exist in conf.. Not gonna do anything here.."
            }
            else {
                $EmailDomains = ($Config.EmailDomains) -split ','
                $EmailDomains += $Domain
                Set-SQLEntConfig -Organization $Organization -EmailDomains $EmailDomains
            }
        }
        catch {
            throw "Error updating config: $_"
        }

        Get-PSSession | Remove-PSSession
    }
}