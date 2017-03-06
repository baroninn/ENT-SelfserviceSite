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
        $ADUsers += Get-ADUser -Credential $Cred -Server ("$ORganization-dc01.$($Config.DomainFQDN)") -SearchBase $Config.CustomerOUDN -LDAPFilter "(DisplayName=*)(!DisplayName=*_Template_*)(UserPrincipalName=*)" -Properties DisplayName, DistinguishedName}
        else{$ADUsers += Get-ADUser -Credential $Cred -Server ("$ORganization-dc-01.$($Config.DomainFQDN)") -SearchBase $Config.CustomerOUDN -LDAPFilter "(DisplayName=*)(!DisplayName=*_Template_*)(UserPrincipalName=*)" -Properties DisplayName, DistinguishedName}

        $UserObject = @()
        foreach ($user in $ADUsers) {
                $UserObject += 
                  [pscustomobject]@{
                      Name              = $user.DisplayName
                      DistinguishedName = $user.DistinguishedName
                      UserPrincipalName = $user.UserPrincipalName
                  }
            }
            
        return $UserObject
    }
}
