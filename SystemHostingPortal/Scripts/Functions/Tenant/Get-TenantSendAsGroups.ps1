function Get-TenantSendAsGroups {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, 
                   ValueFromPipeline)]
        [string]$TenantName
    )
    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2

        $Config = Get-TenantConfig -TenantName $TenantName

    }
    Process {
        
        $Groups = @()
        $Groups += Get-ADGroup -Filter 'Name -like "*_SendAs"' -SearchBase $Config.MailboxGroupsOU -Server $Config.DomainFQDN -Properties Description

        #$Groups
        $Sikkermail = @()
        foreach ($group in $groups) {
            if ($group.Description -eq $null) {
                $Sikkermail += 
                  [pscustomobject]@{
                      Organization      = $TenantName
                      Description       = "NOT Sikkermail"
                      DistinguishedName = $group.DistinguishedName
                      Name              = $group.Name
                      SID               = $group.SID
                  }
            }
        else {
                $Sikkermail += 
                  [pscustomobject]@{
                      Organization      = $TenantName
                      Description       = $group.Description
                      DistinguishedName = $group.DistinguishedName
                      Name              = $group.Name
                      SID               = $group.SID
                  }
            }
        }
            
        return $Sikkermail
    }
}
