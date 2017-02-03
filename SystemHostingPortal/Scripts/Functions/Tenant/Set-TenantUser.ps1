function Set-TenantUser {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('CustomAttribute1')]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [bool]$ExcludeFromMailboxAutoResize
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
        
        Import-Module (New-ExchangeProxyModule -Command 'Set-Mailbox')
    }

    Process {
        $mbx = Get-TenantMailbox -TenantName $TenantName -Name $Name

        $newProperties = @{
            ExcludeFromMailboxAutoResize = $ExcludeFromMailboxAutoResize
        }

        $mbx | Set-Mailbox -CustomAttribute10 (ConvertTo-Json -InputObject $newProperties -Compress)
    }
}