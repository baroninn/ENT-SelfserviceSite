function Remove-EmailAddress {
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
        $EmailAddress
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Config = Get-SQLEntConfig -Organization $Organization
        $Cred   = Get-RemoteCredentials -Organization $Organization

    }

    Process {

        $User = Get-ADUser ($Name -split '@')[0] -Credential $Cred -Server $Config.DomainFQDN -Properties Proxyaddresses
        $Proxy = $User.Proxyaddresses

            $Proxy = $User.Proxyaddresses

            foreach ($i in $proxy) {
                if ($i -clike "SMTP:$EmailAddress") {
                    throw "$EmailAddress is the primary. Please change this first.."
                }
            }

        Set-ADUser $User -Remove @{Proxyaddresses="smtp:$EmailAddress"} -Server $Config.DomainFQDN -Credential $Cred | Out-Null

        if ($Config.AADsynced -eq 'true') {
            Start-Dirsync -Organization $Organization -Policy 'delta'
            Write-Output "Directory sync has been initiated, because the customer has Office365."
        }

    }
    
}