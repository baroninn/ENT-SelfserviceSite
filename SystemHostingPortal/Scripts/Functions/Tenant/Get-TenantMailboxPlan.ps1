function Get-TenantMailboxPlan {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('CustomAttribute1')]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Name
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }
    Process {
        $mbx = Get-TenantMailbox -TenantName $TenantName -Name $Name -Single

        if ($mbx.ProhibitSendReceiveQuota -eq 'Unlimited') {
            $mbx.ProhibitSendReceiveQuota
        }
        else {
            $mbx.ProhibitSendReceiveQuota.Substring(0, $mbx.ProhibitSendReceiveQuota.IndexOf('(')).Replace(' ', '')
        } 
    }
}