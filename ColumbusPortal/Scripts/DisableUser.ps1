param(
    [parameter(Mandatory=$true)]
    $Organization,
    [parameter(Mandatory=$true)]
    $UserPrincipalName,
    [switch]$Confirm = $true
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)


$Config = Get-SQLEntConfig -Organization $Organization
$Cred  = Get-RemoteCredentials -Organization $Organization

if($Confirm) {

    Disable-ADAccount -Identity ($UserPrincipalName -split '@')[0] -Server $Config.DomainFQDN -Credential $Cred

    if ($Config.AADsynced -eq 'true') {
        Start-Dirsync -Organization $Organization
        Write-Output "Directory sync has been initiated, because the customer has Office365."
    }

    ## Make mailbox changes..
    try {
        Import-Module (New-ExchangeProxyModule -Organization $Organization -Command Get-Mailbox, Set-Mailbox)
        $mbx = Get-Mailbox -Identity $UserPrincipalName -ErrorAction SilentlyContinue
        if($mbx) {
            Set-Mailbox -HiddenFromAddressListsEnabled $true -Identity $UserPrincipalName
        }
        Else {
            Write-Output "User doesn't appear to have a mailbox, skipping mail settings.."
        }
    }
    catch {
        throw $_
    }
    Get-PSSession | Remove-PSSession
}