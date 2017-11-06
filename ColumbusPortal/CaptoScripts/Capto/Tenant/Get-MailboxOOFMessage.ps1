function Get-MailboxOOFMessage {
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

        Import-Module (New-ExchangeProxyModule -Command "Get-Mailbox", "Get-MailboxAutoReplyConfiguration")
    }
    Process {
        $params = @{
            ErrorAction = "Stop"
            Identity    = $UserPrincipalName
        }

        $result = Get-MailboxAutoReplyConfiguration @params
        
        return $result
    }

    End {
    }
}