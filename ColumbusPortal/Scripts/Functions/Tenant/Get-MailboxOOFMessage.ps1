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

        Import-Module (New-ExchangeProxyModule -Organization $Organization -Command "Get-Mailbox", "Get-MailboxAutoReplyConfiguration")
    }
    Process {
        $params = @{
            ErrorAction = "Stop"
            Identity    = $UserPrincipalName
        }

        $result = Get-MailboxAutoReplyConfiguration @params
        $result.StartTime = "{0:MM-dd-yyyy HH:mm}" -f $result.StartTime
        $result.EndTime = "{0:MM-dd-yyyy HH:mm}" -f $result.EndTime
        
        return $result
    }

    End {
    }
}