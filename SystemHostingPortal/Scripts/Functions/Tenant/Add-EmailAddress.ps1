function Add-EmailAddress {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Organization,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $EmailAddress,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]
        $SetAsPrimary
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Config = Get-EntConfig -Organization $Organization
        $Cred   = Get-RemoteCredentials -Organization $Organization

    }

    Process {
        
        if ($Config.ExchangeServer -ne "null") {

            Import-Module (New-ExchangeProxyModule -Organization $Organization -Command Get-Mailbox, Set-Mailbox)

            try {
                Set-Mailbox -Identity $Name -EmailAddresses @{Add=$EmailAddress}
            }
            catch {
                throw $_
            }


        }
        else {

            $User = Get-ADUser ($Name -split '@')[0] -Credential $Cred -Server $Config.DomainFQDN -Properties Proxyaddresses
            $Proxy = $User.Proxyaddresses

            if ($SetAsPrimary) {

                $Proxy = $User.Proxyaddresses

                foreach ($i in $proxy) {
                    if ($i -clike "SMTP:*") {
                        $OldPrimaryProxy = $i -creplace "SMTP:", "smtp:"
                        Set-ADUser $user -Remove @{Proxyaddresses="$i"}
                        Set-ADUser $user -Add @{Proxyaddresses="$OldPrimaryProxy"}
                    }
                }

                Set-ADUser $User -Add @{Proxyaddresses="SMTP:$EmailAddress"} -Server $Config.DomainFQDN -Credential $Cred | Out-Null
            }
            else {
                Set-ADUser $User -Add @{Proxyaddresses="smtp:$EmailAddress"} -Server $Config.DomainFQDN -Credential $Cred | Out-Null
            }

            if ($Config.AADsynced -eq 'true') {
                Start-Dirsync -Organization $Organization
                Write-Output "Directory sync has been initiated, because the customer has Office365."
            }

        }
    
    }
}