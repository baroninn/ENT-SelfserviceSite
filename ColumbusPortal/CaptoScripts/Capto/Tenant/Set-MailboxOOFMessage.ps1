function Set-MailboxOOFMessage {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Organization,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$UserPrincipalName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime]$StartTime,

        [Parameter(ValueFromPipelineByPropertyName)]
        [datetime]$EndTime,

        [String]$Internal,

        [String]$External
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Import-Module (New-ExchangeProxyModule -Command "Get-Mailbox", "Get-MailboxAutoReplyConfiguration", "Set-MailboxAutoReplyConfiguration")
    }
    Process {

        try {
            if ($StartTime -or $EndTime) {
                if ($Internal -and -not $External) {
                    Set-MailboxAutoReplyConfiguration -Identity $UserPrincipalName -InternalMessage $Internal -ExternalAudience None -AutoReplyState:Scheduled -StartTime $StartTime -EndTime $EndTime
                }
                if ($External -and -not $Internal) {
                    Set-MailboxAutoReplyConfiguration -Identity $UserPrincipalName -ExternalMessage $External -ExternalAudience All -AutoReplyState:Scheduled -StartTime $StartTime -EndTime $EndTime
                }
                if ($Internal -and $External) {
                    Set-MailboxAutoReplyConfiguration -Identity $UserPrincipalName -InternalMessage $Internal -ExternalMessage $External -ExternalAudience All -AutoReplyState:Scheduled -StartTime $StartTime -EndTime $EndTime
                }
            }
            else {
                if ($Internal -and -not $External) {
                    Set-MailboxAutoReplyConfiguration -Identity $UserPrincipalName -InternalMessage $Internal -ExternalAudience None -AutoReplyState:Enabled
                }
                if ($External -and -not $Internal) {
                    Set-MailboxAutoReplyConfiguration -Identity $UserPrincipalName -ExternalMessage $External -ExternalAudience All -AutoReplyState:Enabled
                }
                if ($Internal -and $External) {
                    Set-MailboxAutoReplyConfiguration -Identity $UserPrincipalName -InternalMessage $Internal -ExternalMessage $External -ExternalAudience All -AutoReplyState:Enabled
                }
            }
        }
        catch {
            throw $_
        }

    }

    End {
    }
}