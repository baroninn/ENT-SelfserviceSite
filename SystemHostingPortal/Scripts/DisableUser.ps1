param(
    [parameter(Mandatory=$true)]
    $Organization,
    [parameter(Mandatory=$true)]
    $DistinguishedName,
    [switch]$Confirm = $true
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)


$Config = Get-EntConfig -Organization $Organization
$Cred  = Get-RemoteCredentials -Organization $Organization


if($Confirm) {
    
    if($Organization -eq "ASG"){
        $user = @(Get-ADUser -Credential $Cred -Server "$Organization-DC01.$($Config.DomainFQDN)" -Identity $DistinguishedName)
        Disable-ADAccount -Identity $DistinguishedName -Server "$Organization-DC01.$($Config.DomainFQDN)" -Credential $Cred
    }
    else{
        $user = @(Get-ADUser -Credential $Cred -Server "$Organization-DC-01.$($Config.DomainFQDN)" -Identity $DistinguishedName)
        Disable-ADAccount -Identity $DistinguishedName -Server "$Organization-DC-01.$($Config.DomainFQDN)" -Credential $Cred
    }

    if($Config.ExchangeServer -ne "null"){
        try {
            Import-Module (New-ExchangeProxyModule -Organization $Organization -Command Get-Mailbox, Set-Mailbox)
            $mbx = Get-Mailbox -Identity $user.UserPrincipalName
            if($mbx) {
                Set-Mailbox -HiddenFromAddressListsEnabled $true -Identity $user.UserPrincipalName
            }
            Else {
                Write-Verbose "User doesn't appear to have a mailbox, skipping.."
            }
        }
        catch {
            throw $_
        }
    }
    if($Config.TenantID365 -ne "null"){
        try {
            Connect-O365 -Organization $Organization
            $mbx = Get-Mailbox -Identity $user.UserPrincipalName
            if($mbx) {
                Set-Mailbox -HiddenFromAddressListsEnabled $true -Identity $user.UserPrincipalName
            }
            Else {
                Write-Verbose "User doesn't appear to have a mailbox, skipping.."
            }
        }
        catch {
            throw $_
        }
    }

}