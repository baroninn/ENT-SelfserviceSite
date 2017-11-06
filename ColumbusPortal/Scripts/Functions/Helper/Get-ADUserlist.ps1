function Get-ADUserlist {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Organization,

        [string]$UserPrincipalName
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Config = Get-SQLEntConfig -Organization $Organization
        $Cred  = Get-RemoteCredentials -Organization $Organization
        $Env:ADPS_LoadDefaultDrive = 0
        Import-Module ActiveDirectory -Cmdlet "Get-ADUser", "Set-ADUser" > $null
    }
    Process {
        
        if ($UserPrincipalName) {
        $ADUser = @(Get-ADUser -Credential $Cred -Server $Config.DomainFQDN -Identity ($UserPrincipalName -split '@')[0] -Properties DisplayName, DistinguishedName, Enabled, proxyAddresses, EmailAddress)

        $UserObject = @()
            ## test for proxy existence..
            try {
                $proxyexist = ($ADUser.proxyAddresses -join ',')
            }
            catch { 
                $proxyexist = $null
                Set-ADUser -Credential $Cred -Server $Config.DomainFQDN -Identity ($UserPrincipalName -split '@')[0] -Add @{proxyAddresses='SMTP:' + $UserPrincipalName.ToLower()}
            }
            try {
                $mailexist = ($ADUser.EmailAddress[0])
            }
            catch {
                Set-ADUser -Credential $Cred -Server $Config.DomainFQDN -Identity ($UserPrincipalName -split '@')[0] -EmailAddress $UserPrincipalName.ToLower()
            }


            if (!$proxyexist) {
                $UserObject +=
                    [pscustomobject]@{
                        proxyAddresses = "SMTP:$($ADUser.UserPrincipalName)"
                        }
            }
            else {
                $Proxies = ($ADUser.proxyAddresses -join ',')

                $UserObject +=
                    [pscustomobject]@{
                        proxyAddresses = $Proxies
                        }
            }
        }
        else {

            $ADUsers = @(Get-ADUser -Credential $Cred -Server $Config.DomainFQDN -SearchBase $Config.CustomerOUDN -LDAPFilter "(DisplayName=*)(UserPrincipalName=*)" -Properties DisplayName, DistinguishedName, Enabled | sort DisplayName)
            #$ADUsers += Get-ADUser -Credential $Cred -Server $Config.DomainFQDN -SearchBase $Config.CustomerOUDN -Filter "DisplayName -like '*' -and UserPrincipalName -like '*'" -Properties DisplayName, DistinguishedName, Enabled, proxyAddresses -AuthType Negotiate


            $UserObject = @(
                foreach ($user in $ADUsers) {
                    if($user.Enabled -eq $false) {

                          [pscustomobject]@{
                              Name              = $user.DisplayName
                              DistinguishedName = $user.DistinguishedName
                              UserPrincipalName = $user.UserPrincipalName
                              #proxyAddresses    = $user.proxyAddresses
                              Enabled           = 'Disabled'
                          }
                    }
                    if($user.Enabled -eq $true) {

                          [pscustomobject]@{
                              Name              = $user.DisplayName
                              DistinguishedName = $user.DistinguishedName
                              UserPrincipalName = $user.UserPrincipalName
                              #proxyAddresses    = $user.proxyAddresses
                              Enabled           = 'Enabled'
                          }
                    }
                }
            )
        }
            
        return $UserObject
    }
}
