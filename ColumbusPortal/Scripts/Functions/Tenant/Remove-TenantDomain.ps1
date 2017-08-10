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

    $Config = Get-SQLEntConfig -Organization $Organization
    $Cred  = Get-RemoteCredentials -Organization $Organization

    }

    Process {

        if ($RemoveasEmail) {
            if ($Config.Office365.TenantID -ne "null") {
                Connect-O365 -Organization $Organization
            
                try {
                    
                    $MSOLDomains = Get-MsolDomain |select -ExpandProperty Name
                    if ($MSOLDomains -match $Domain) {
                        Remove-MsolDomain -DomainName $Domain -Force | Out-Null
                    }
                    else {
                        Write-Output "$Domain doesn't exist in Office365.. Not gonna do anything here.."
                    }
                }
                catch {
                    throw "Remove-MSOLDomain - Error: $_"
                }
            }

            if ($Config.ExchangeServer -ne "null") {
            
                Import-Module (New-ExchangeProxyModule -Organization $Organization -Command 'Remove-AcceptedDomain', 'Get-AcceptedDomain')

                try {
                    $accepteddomains = Get-AcceptedDomain | select -ExpandProperty DomainName
                    
                    if ($accepteddomains -match $Domain) {
                        Remove-AcceptedDomain -Identity $Domain -Confirm:$false | Out-Null
                    }
                    else {
                        Write-Output "$Domain doesn't exist in Exchange.. Not gonna do anything here.."
                    }
                }
                catch {
                    throw "Remove-AcceptedDomain - Error: $_"
                }
            }
        }


        try {
            $Forest = Get-ADForest -Server $Config.DomainFQDN -Credential $Cred

            if ($Forest.UPNSuffixes.ValueList -match $Domain) {
                Set-ADForest -Identity $Forest -Server $Config.DomainFQDN -UPNSuffixes @{Remove=$Domain} -Credential $Cred | Out-Null
            }
            else {
                Write-Output "$Domain doesn't exist in forest.. Moving on.."
            }
        }
        catch { 

            throw "Set-Adforest - Error: $_"
        }

        ## Update Config without the specified domain..
        try {
            
            if ($Config.EmailDomains.DomainName -match $Domain) {
                ## Because object is of fixed size, we need to create a new array, and overwrite the sub-object..
                $NewDomains = @()
                foreach ($i in $Config.EmailDomains.DomainName) {
                    if ($i -ne $Domain) {
                            $NewDomains += $i
                    }
                }
                Set-EntConfig -Organization $Organization -Domains $NewDomains | Out-Null
            }
            else {

                Write-Output "$Domain doesn't exist in conf.. Not gonna do anything here.."
            }
        }
        catch {
            throw "Error updating config: $_"
        }

        Get-PSSession | Remove-PSSession
    }
}