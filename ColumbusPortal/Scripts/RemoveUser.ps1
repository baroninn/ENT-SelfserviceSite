param(
    [parameter(Mandatory=$true)]
    $Organization,

    [parameter(Mandatory=$true)]
    $UserPrincipalName,

    [switch]$DelData
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot Functions)


$Config = Get-SQLEntConfig -Organization $Organization
$Cred  = Get-RemoteCredentials -Organization $Organization

$User = Get-ADUser -Identity ($UserPrincipalName -split '@')[0] -Server $Config.DomainFQDN -Credential $Cred -Properties homeDirectory

try {
    Remove-ADUser $user -Server $Config.DomainFQDN -Credential $Cred -Confirm:$false
}
catch {
    throw $_
}
<#
if ($Config.ExchangeServer -ne "null") {

    Import-Module (New-ExchangeProxyModule -Organization $Organization -Command 'Get-Mailbox', 'Enable-Mailbox', 'Remove-Mailbox')

    try {
        Remove-Mailbox -Identity $UserPrincipalName -Confirm:$false
    }
    catch {
        throw "Mailbox removal failed with: $_"
    }
}
else {

    try {
        Remove-ADUser $user -Server $Config.DomainFQDN -Credential $Cred -Confirm:$false
    }
    catch {
        throw $_
    }
}
#>
if ($user.HomeDirectory -notlike $null -and $DelData) {

        $scriptblock = {
            param($user)

            $path = $user.HomeDirectory

            try {
                $Path | Remove-Item -Recurse -Force
            }
            catch {
                Write-Output "Unable to remove user folder '$Path'. You must do this manually"
            }
        }

    Invoke-Command -ComputerName $Config.DomainDC -ScriptBlock $scriptblock -Credential $Cred -ArgumentList $user
}

if ($Config.AADsynced -eq 'true') {
    Start-Dirsync -Organization $Organization -Policy 'delta'
    Write-Output "Directory sync has been initiated, because the customer has Office365."
}