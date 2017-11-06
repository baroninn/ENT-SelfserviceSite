[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]
    $UserPrincipalName,

    [Parameter(Mandatory)]
    [string]
    $ForwardingAddress,

    [Parameter(Mandatory)]
    [ValidateSet("Internal", "External", "Clear")]
    [string]
    $ForwardingType,

    [bool]
    $DeliverToMailboxAndForward
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$Config = Get-SQLEntConfig -Organization $Organization

Import-Module (New-ExchangeProxyModule -Organization $Organization -Command "Get-Mailbox", "Set-Mailbox")

if ($config.ExchangeServer -eq $null -and $Config.TenantID -eq $null) {

    Throw "$Organization doesn't appear to have any mail service running.. Please check config if this is wrong.."
}
else {

    $mbx = Get-TenantMailbox -Organization $Organization -Name $UserPrincipalName -Single

    switch ($ForwardingType) {
        "Clear" {
            $mbx | Set-Mailbox -ForwardingAddress $null -ForwardingSmtpAddress $null -ErrorAction Stop
        }
        "Internal" {
            $forwardMbx = Get-TenantMailbox -Organization $Organization -Name $ForwardingAddress
            $mbx | Set-Mailbox -ForwardingAddress $forwardMbx.DistinguishedName -ForwardingSmtpAddress $null -DeliverToMailboxAndForward $DeliverToMailboxAndForward -ErrorAction Stop
        }
        "External" {
            $mbx | Set-Mailbox -ForwardingAddress $null -ForwardingSmtpAddress $ForwardingAddress -DeliverToMailboxAndForward $DeliverToMailboxAndForward -ErrorAction Stop
        }
    }
}
