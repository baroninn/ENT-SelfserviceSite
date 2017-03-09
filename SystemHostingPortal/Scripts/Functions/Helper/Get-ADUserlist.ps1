function Get-ADUserlist {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, 
                   ValueFromPipeline)]
        [string]$Organization
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Config = Get-EntConfig -Organization $Organization -JSON
        $Cred  = Get-RemoteCredentials -Organization $Organization
    }
    Process {
        
        $ADUsers  = @()
        if($Organization -eq "ASG") {
        $ADUsers += Get-ADUser -Credential $Cred -Server ("$Organization-dc01.$($Config.DomainFQDN)") -SearchBase $Config.CustomerOUDN -LDAPFilter "(DisplayName=*)(UserPrincipalName=*)" -Properties DisplayName, DistinguishedName, Enabled | sort Name}
        else{$ADUsers += Get-ADUser -Credential $Cred -Server ("$ORganization-dc-01.$($Config.DomainFQDN)") -SearchBase $Config.CustomerOUDN -LDAPFilter "(DisplayName=*)(UserPrincipalName=*)" -Properties DisplayName, DistinguishedName, Enabled | sort Name}

        $UserObject = @()
        foreach ($user in $ADUsers) {
            if($user.Enabled -eq $false) {
                $UserObject += 
                  [pscustomobject]@{
                      Name              = $user.DisplayName
                      DistinguishedName = $user.DistinguishedName
                      UserPrincipalName = $user.UserPrincipalName
                      Enabled           = 'Disabled'
                  }
            }
            if($user.Enabled -eq $true) {
                $UserObject += 
                  [pscustomobject]@{
                      Name              = $user.DisplayName
                      DistinguishedName = $user.DistinguishedName
                      UserPrincipalName = $user.UserPrincipalName
                      Enabled           = 'Enabled'
                  }
            }
        }
            
        return $UserObject
    }
}
