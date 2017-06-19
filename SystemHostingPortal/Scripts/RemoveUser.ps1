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


$Config = Get-EntConfig -Organization $Organization
$Cred  = Get-RemoteCredentials -Organization $Organization

   
try {
    $user = Get-ADUser -Identity ($UserPrincipalName -split '@')[0] -Server $Config.DomainFQDN -Credential $Cred
    Remove-ADUser $user -Server $Config.DomainFQDN -Credential $Cred -Confirm:$false
}
catch {
    throw $_
}

if ($user.HomeDirectory -notlike $null -and $DelData) {

        $scriptblock = {
            param($user)

            $path = $user.HomeDirectory

            try {
                robocopy C:\DontDelete "$Path" /purge | out-null
                $Path | Remove-Item -Recurse -Force
            }
            catch {
                Write-Output "Unable to remove user folder '$Path'. You must do this manually"
            }
        }

    Invoke-Command -ComputerName $Config.DomainDC -ScriptBlock $scriptblock -Credential $Cred -ArgumentList $user

}