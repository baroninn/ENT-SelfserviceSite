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

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

Import-Module (New-ExchangeProxyModule -Command "Set-Mailbox")

$mbx = Get-TenantMailbox -TenantName $Organization -Name $UserPrincipalName -Single

switch ($ForwardingType) {
    "Clear" {
        $mbx | Set-Mailbox -ForwardingAddress $null -ForwardingSmtpAddress $null -ErrorAction Stop
    }
    "Internal" {
        $forwardMbx = Get-TenantMailbox -TenantName $Organization -Name $ForwardingAddress
        $mbx | Set-Mailbox -ForwardingAddress $forwardMbx.DistinguishedName -ForwardingSmtpAddress $null -DeliverToMailboxAndForward $DeliverToMailboxAndForward -ErrorAction Stop
    }
    "External" {
        $mbx | Set-Mailbox -ForwardingAddress $null -ForwardingSmtpAddress $ForwardingAddress -DeliverToMailboxAndForward $DeliverToMailboxAndForward -ErrorAction Stop
    }
}