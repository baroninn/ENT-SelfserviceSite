function Add-TenantDomain {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TenantName,
        [Parameter(Mandatory)]
        [string]$Domain,

        [switch]$SetAsUPN
    )

    Begin {

    $ErrorActionPreference = "Stop"

    Import-Module (New-ExchangeProxyModule -Command "Get-Mailbox", "Get-AcceptedDomain", "New-AcceptedDomain")
    Import-Module ActiveDirectory
    $ENTname = "svc_selfservice@hosting.capto.dk"
    $ENTpass = ConvertTo-SecureString 'kdi*D*8djdjHBsbdnmsfhHHgdgdgd' -AsPlainText -Force
    $EntCred = New-Object System.Management.Automation.PSCredential $ENTname, $ENTpass

    $Config = Get-TenantConfig -TenantName $TenantName

    }

    Process {

        if ($SetAsUPN) {
            try{
                Set-ADForest -Identity 'hosting.capto.dk' -Server $Config.DomainFQDN -UPNSuffixes @{Add=$Domain} -Credential $EntCred
                    }catch
                        { throw "Set-Adforest - Error: $_"
            }

            try{
                Set-ADOrganizationalUnit -Identity ("OU=" + $config.OUs[1].Name + "," + $config.OUs[1].path) -Add @{uPNSuffixes=$Domain} -Server $Config.DomainFQDN
                    }catch
                        { throw "Set-ADOrganizationalUnit - Error: $_"
            }

        }
        try{
        New-AcceptedDomain -Name ($TenantName + " - " + $Domain) -DomainName $Domain -DomainType Authoritative
            }catch
                { throw "New-AcceptedDomaint - Error: $_"
        }

    }
}