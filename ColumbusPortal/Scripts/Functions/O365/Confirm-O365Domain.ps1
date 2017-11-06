function Confirm-O365Domain {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,

        [Parameter(Mandatory)]
        [string]$Domain
    )

    Begin {

    $ErrorActionPreference = "Stop"

    $Config = Get-SQLEntConfig -Organization $Organization

    }

    Process {

            Connect-MSOnline -Organization $Organization
            
            try {
                Confirm-MsolDomain -DomainName $Domain
            }
            catch {
                throw "Please make sure you have created the following DNS TXT record: " + (Get-MsolDomainVerificationDns -Mode DnsTXTRecord -DomainName $Domain | select -ExpandProperty text) + " - ERROR: $($_.exception)"
            }

    }
}