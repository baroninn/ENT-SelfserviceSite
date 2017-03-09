function New-TenantUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Organization,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Password,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$CopyFrom,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$PasswordNeverExpires,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [string]$PrimarySmtpAddress,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [string]$FirstName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [string]$LastName,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [bool]$TestUser
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        $Cred = Get-RemoteCredentials -Organization $Organization
    }
    Process {
        $Organization = $Organization.ToUpper()


        if ($PrimarySmtpAddress.IndexOf('@') -ne -1) {
            $alias  = $PrimarySmtpAddress.Substring(0, $PrimarySmtpAddress.IndexOf('@'))
            $domain = $PrimarySmtpAddress.Substring($PrimarySmtpAddress.IndexOf('@') + 1)
            if ($alias -eq $null -or $alias -eq '') {
                Write-Error "PrimarySmtpAddress '$PrimarySmtpAddress' does not have a valid alias."
            }
            elseif ($domain -eq $null -or $domain -eq '') {
                Write-Error "PrimarySmtpAddress '$PrimarySmtpAddress' does not have a valid domain."
            }
        }
        else {
            Write-Error "PrimarySmtpAddress '$PrimarySmtpAddress' is not a valid e-mail address."
        }

        $Config = Get-EntConfig -Organization $Organization -JSON

        $OrganizationDomains = @($Config.EmailDomains)
        if (-not ($OrganizationDomains.Where{$_.DomainName -eq "$domain"})) {
            Write-Error "Domain '$domain' was not found for the tenant '$Organization'."
        }

        # SAMAccountName must be 20 chars or less.
        $SAMAccountName = ($PrimarySmtpAddress.Split('@')[0])
        if ($SAMAccountName.Length -gt 20) {
            $SAMAccountName = $SAMAccountName.Substring(0, 19)
        }

        Write-Verbose "SAMAccountName: $SAMAccountName"

        $ADinstance = Get-ADUser $CopyFrom -Credential $Cred -Server $Config.DomainFQDN -Properties accountExpires,assistant,codePage,countryCode,c,division,employeeType,homeDirectory,homeDrive,memberOf,localeID,logonHours,logonWorkstation,manager,postalAddress,postalCode,postOfficeBox,profilePath,scriptPath,street,co,title
                                                                                                    
        $newUserParams = @{
            Name              = "$FirstName $LastName"
            Enabled           = $true
            SamAccountName    = $SAMAccountName
            DisplayName       = "$FirstName $LastName"
            AccountPassword   = (ConvertTo-SecureString -String $Password -AsPlainText -Force) 
            Path              = $ADinstance.DistinguishedName -replace '^cn=.+?(?<!\\),'
            UserPrincipalName = $PrimarySmtpAddress
            GivenName         = $FirstName
            Surname           = $LastName
            Server            = $Config.DomainFQDN
            PassThru          = $null
        }


        if ($PasswordNeverExpires) {
            $newUserParams.Add("PasswordNeverExpires", $true)
        }

        $newUser = New-ADUser @newUserParams -Credential $Cred -Instance $ADinstance

        $Memberof   = Get-ADPrincipalGroupMembership -Identity $ADinstance
        foreach($i in $Memberof){
            if($TestUser){
                if(!($i.name -eq "Domain Users" -or $i.name -eq "G_FullUsers" -or $i.name -eq "G_LightUsers")){
                   Add-ADGroupMember -Identity $i.distinguishedName -Members $newUser -Credential $Cred -Server $Config.DomainFQDN
                }
            }
            else{
                if(!($i.name -eq "Domain Users")){
                   Add-ADGroupMember -Identity $i.distinguishedName -Members $newUser -Credential $Cred -Server $Config.DomainFQDN
                }
            }
        }
        
        if($ADinstance.HomeDirectory -notlike $null){
        Set-ADUser -Identity $newUser -HomeDirectory ($ADinstance.HomeDirectory -replace $ADinstance.SamAccountName, $newUser.SamAccountName) -Credential $Cred -Server $Config.DomainFQDN
        }

        if($ADinstance.ProfilePath -notlike $null){
        Set-ADUser -Identity $newUser -ProfilePath ($ADinstance.ProfilePath -replace $ADinstance.SamAccountName, $newUser.SamAccountName) -Credential $Cred -Server $Config.DomainFQDN
        }

        if ($TestUser) {
        Set-ADUser -Identity $newUser -Add @{extensionAttribute2 = 'TESTUSER'}
        }

    }
}