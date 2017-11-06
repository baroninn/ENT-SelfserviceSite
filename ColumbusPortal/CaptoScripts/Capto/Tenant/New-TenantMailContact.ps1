function New-TenantMailContact {
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
        $ExternalEmailAddress
    )

    Begin {
        $ErrorActionPreference = "Stop"
        Set-StrictMode -Version 2

        Import-Module (New-ExchangeProxyModule -Command "New-MailContact", "Set-MailContact")
    }

    Process {
        $Config = Get-TenantConfig -TenantName $TenantName

        $mailContact = New-MailContact -Name $Name -ExternalEmailAddress $ExternalEmailAddress -OrganizationalUnit $Config.UsersOU

        $mailContact | Set-MailContact -CustomAttribute1 $TenantName
    }
}