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
        Import-Module ActiveDirectory -Cmdlet "Get-ADUser", "Set-ADUser"
    }
    Process {
        
        if ($UserPrincipalName) {
        $ADUser  = @()
        $ADUser += Get-ADUser -Credential $Cred -Server $Config.DomainFQDN -Identity ($UserPrincipalName -split '@')[0] -Properties DisplayName, DistinguishedName, Enabled, proxyAddresses | sort Name

        $UserObject = @()
            ## test for proxy existence..
            try {
                $exist = ($ADUser.proxyAddresses -join ',')
            }
            catch { 
                $exist = $null
                Set-ADUser -Credential $Cred -Server $Config.DomainFQDN -Identity ($UserPrincipalName -split '@')[0] -Add @{proxyAddresses='SMTP:' + $UserPrincipalName.ToLower()}
            }


            if (!$exist) {
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

            $ADUsers  = @()
            $ADUsers += Get-ADUser -Credential $Cred -Server $Config.DomainFQDN -SearchBase $Config.CustomerOUDN -LDAPFilter "(DisplayName=*)(UserPrincipalName=*)" -Properties DisplayName, DistinguishedName, Enabled, proxyAddresses | sort Name

            $UserObject = @()
            foreach ($user in $ADUsers) {
                if($user.Enabled -eq $false) {
                    $UserObject += 
                      [pscustomobject]@{
                          Name              = $user.DisplayName
                          DistinguishedName = $user.DistinguishedName
                          UserPrincipalName = $user.UserPrincipalName
                          proxyAddresses    = $user.proxyAddresses
                          Enabled           = 'Disabled'
                      }
                }
                if($user.Enabled -eq $true) {
                    $UserObject += 
                      [pscustomobject]@{
                          Name              = $user.DisplayName
                          DistinguishedName = $user.DistinguishedName
                          UserPrincipalName = $user.UserPrincipalName
                          proxyAddresses    = $user.proxyAddresses
                          Enabled           = 'Enabled'
                      }
                }
            }
        }
            
        return $UserObject
    }
}
