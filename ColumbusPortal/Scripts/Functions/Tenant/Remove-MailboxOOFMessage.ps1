function Remove-MailboxOOFMessage {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Organization,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$UserPrincipalName
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Import-Module (New-ExchangeProxyModule -Organization $Organization -Command "Set-MailboxAutoReplyConfiguration", "Get-MailboxAutoReplyConfiguration")
    }
    Process {

        try {
            if ((Get-MailboxAutoReplyConfiguration -Identity $UserPrincipalName).AutoReplyState -eq 'Disabled') {
                throw "Autoreply for $UserPrincipalName is already disabled.."
            }
            else {
                Set-MailboxAutoReplyConfiguration -Identity $UserPrincipalName -AutoReplyState:Disabled
            }
        }
        catch {
            throw $_
        }

    }

    End {
    }
}