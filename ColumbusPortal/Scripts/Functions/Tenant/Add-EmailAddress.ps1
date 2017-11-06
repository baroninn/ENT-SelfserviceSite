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
        [switch]
        $SetAsPrimary
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Config = Get-SQLEntConfig -Organization $Organization
        $Cred   = Get-RemoteCredentials -Organization $Organization

    }

    Process {
        
        if (-not [string]::IsNullOrWhiteSpace($Config.ExchangeServer)) {

            Import-Module (New-ExchangeProxyModule -Organization $Organization -Command Get-Mailbox, Set-Mailbox)

            try {
                if ($SetAsPrimary) {
                    Set-Mailbox -Identity $Name -PrimarySmtpAddress "$($EmailAddress)"
                }
                else {
                    Set-Mailbox -Identity $Name -EmailAddresses @{Add="smtp:$($EmailAddress)"}
                }
            }
            catch {
                throw $_
            }


        }
        else {

            $User = Get-ADUser ($Name -split '@')[0] -Credential $Cred -Server $Config.DomainFQDN -Properties Proxyaddresses
            $Proxy = $User.Proxyaddresses

            if ($SetAsPrimary) {

                foreach ($i in $proxy) {
                    if ($i -clike "SMTP:*") {
                        $OldPrimaryProxy = $i -creplace "SMTP:", "smtp:"
                        Set-ADUser $user -Remove @{Proxyaddresses="$i"}
                        Set-ADUser $user -Add @{Proxyaddresses="$OldPrimaryProxy"}
                    }
                    elseif ($i -clike "smtp:*") {
                        Set-ADUser $user -Remove @{Proxyaddresses="$i"}
                    }
                }

                Set-ADUser $User -Add @{Proxyaddresses="SMTP:$EmailAddress"} -EmailAddress $EmailAddress -Server $Config.DomainFQDN -Credential $Cred > $null
            }
            else {
                Set-ADUser $User -Add @{Proxyaddresses="smtp:$EmailAddress"} -Server $Config.DomainFQDN -Credential $Cred > $null
            }

            if ($Config.AADsynced -eq 'true') {
                Start-Dirsync -Organization $Organization -Policy 'delta'
                Write-Output "Directory sync has been initiated, because the customer has Office365."
            }

        }
    
    }
}