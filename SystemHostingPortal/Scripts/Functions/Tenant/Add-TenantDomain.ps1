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

    $Config = Get-EntConfig -Organization $Organization -JSON
    $Cred  = Get-RemoteCredentials -Organization $Organization

    }

    Process {

        if ($AddasEmail) {
            
            if ($Config.ExchangeServer -eq "null") {
                Connect-O365 -Organization $Organization
            
                try {
                    New-MsolDomain -Name $Domain | Out-Null
                }
                catch {
                    throw "New-MSOLDomain - Error: $_"
                }

                try {
                    $DNS = (Get-MsolDomainVerificationDns -DomainName $Domain).Label.split('.')[0]
                }
                catch {
                    throw "Error getting verification DNS in O365 : $_"
                }
                Write-Output "Please create this TXT record in the DNS zone: MS=$DNS"
            }
            
            else {
                if ($Config.ExchangeServer -ne "null") {
                    
                    Import-Module (New-ExchangeProxyModule -Organization $Organization -Command 'New-AcceptedDomain')

                    try {
                        New-AcceptedDomain -Name $Domain -DomainName $Domain -DomainType Authoritative
                    }
                    catch {
                        throw "ERROR: $_"
                    }
                }

                if ($Config.Office365.TenantID -ne "null") {

                    Connect-O365 -Organization $Organization
            
                    try {
                        New-MsolDomain -Name $Domain | Out-Null
                    }
                    catch {
                        throw "New-MSOLDomain - Error: $_"
                    }

                    try {
                        $DNS = (Get-MsolDomainVerificationDns -DomainName $Domain).Label.split('.')[0]
                    }
                    catch {
                        throw "Error getting verification DNS in O365 : $_"
                    }
                    Write-Output "Please create this TXT record in the DNS zone: MS=$DNS"
                }
            }
                
        }

        try {

            $Forest = Get-ADForest -Server $Config.DomainFQDN -Credential $Cred
            Set-ADForest -Identity $Forest -Server $Config.DomainFQDN -UPNSuffixes @{Add=$Domain} -Credential $Cred

        }
        catch { 

            throw "Set-Adforest - Error: $_"
        }

        ## Update Config with new domain..
        try {
            $Config.EmailDomains.DomainName += $Domain
            $Config | ConvertTo-Json | Out-File ("C:\ENTConfig\$Organization\$Organization.txt") -Force
        }
        catch {
            throw "Error updating config: $_"
        }

        Get-PSSession | Remove-PSSession
    }
}