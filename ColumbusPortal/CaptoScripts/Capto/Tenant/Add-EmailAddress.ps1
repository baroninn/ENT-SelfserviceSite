function Add-EmailAddress {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $TenantName,

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

        Import-Module (New-ExchangeProxyModule -Command "Set-Mailbox")
    }

    Process {
        $mbx = @(Get-TenantMailbox -TenantName $TenantName -Name $Name)

        if ($mbx.Count -eq 0) {
            Write-Error "'$Name' was not found."
        }
        elseif ($mbx.Count -gt 1) {
            Write-Error "Ambiguous parameter Name '$Name'."
        }
    
        $mbx = $mbx[0]

        if ($SetAsPrimary) {
            $mbx.EmailAddresses.Add("SMTP:$EmailAddress") | Out-Null
        }
        else {
            $mbx.EmailAddresses.Add("smtp:$EmailAddress") | Out-Null
        }

        $mbx | Set-Mailbox -EmailAddresses $mbx.EmailAddresses -EmailAddressPolicyEnabled $false

        if ($SetAsPrimary) {
            $mbx | Set-Mailbox -UserPrincipalName $EmailAddress
        }
    }
}