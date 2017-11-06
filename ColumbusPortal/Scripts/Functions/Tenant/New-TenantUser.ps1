function New-TenantUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Organization,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Password,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$CopyFrom,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$PasswordNeverExpires,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$PrimarySmtpAddress,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$FirstName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$LastName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$TestUser,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Displayname,

        [switch]$SharedMailbox
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

        $Config = Get-SQLEntConfig -Organization $Organization

        $OrganizationDomains = @($Config.EmailDomains -split ',')
        if (-not $OrganizationDomains -contains $domain) {
            Write-Error "Domain '$domain' was not found for the tenant '$Organization'."
        }

        # SAMAccountName must be 20 chars or less.
        $SAMAccountName = ($PrimarySmtpAddress.Split('@')[0])
        if ($SAMAccountName.Length -gt 20) {
            $SAMAccountName = $SAMAccountName.Substring(0, 19)
        }

        Write-Verbose "SAMAccountName: $SAMAccountName"

        if(-not $SharedMailbox) {

            $ADinstance = Get-ADUser ($CopyFrom -split '@')[0] -Credential $Cred -Server $Config.DomainFQDN -Properties accountExpires,assistant,codePage,countryCode,c,division,employeeType,homeDirectory,homeDrive,memberOf,localeID,logonHours,logonWorkstation,manager,postalAddress,postalCode,postOfficeBox,profilePath,scriptPath,street,co,title
                                                                                                    
            $newUserParams = @{
                Name              = "$FirstName $LastName"
                Enabled           = $true
                SamAccountName    = $SAMAccountName
                DisplayName       = "$FirstName $LastName"
                AccountPassword   = (ConvertTo-SecureString -String $Password -AsPlainText -Force) 
                Path              = $ADinstance.DistinguishedName -replace '^cn=.+?(?<!\\),'
                UserPrincipalName = $PrimarySmtpAddress
                EmailAddress      = $PrimarySmtpAddress
                GivenName         = $FirstName
                Surname           = $LastName
                Server            = $Config.DomainFQDN
                PassThru          = $null
            }

            if ($PasswordNeverExpires) {
                $newUserParams.Add("PasswordNeverExpires", $true)
            }

            $newUser = New-ADUser @newUserParams -Credential $Cred -Instance $ADinstance

            Wait-ADReplication -UPN $PrimarySmtpAddress -Config $config -Cred $cred -Verbose

            if (-not [string]::IsNullOrWhiteSpace($Config.ExchangeServer)) {

                Import-Module (New-ExchangeProxyModule -Organization $Organization -Command 'Get-Mailbox', 'Enable-Mailbox', 'Get-MailboxDatabase')

                try {
                    Enable-Mailbox -Identity $SAMAccountName -PrimarySmtpAddress $PrimarySmtpAddress
                }
                catch {
                    throw "Mailbox creation failed with: $_"
                }
            }
            else {
                Set-ADUser $newUser -Add @{Proxyaddresses="SMTP:$PrimarySmtpAddress"} -Server $Config.DomainFQDN -Credential $Cred
            }

            ## Try to create the userhome manually..
            if ($ADinstance.HomeDirectory -notlike $null) {

                ## Get UserHome path from existing user
                $DFSPath = ($ADinstance.HomeDirectory).Replace($($ADinstance.SamAccountName), '')

                    $scriptblock = {
                        param($SAMAccountName, $Config, $DFSPath)
                        $rule_parameters = @(
                            "$($Config.Domain)\$SAMAccountName"
                            "FullControl"
                                ,@(
                                    "ContainerInherit"
                                    "ObjectInherit"
                                    )
                            "None"
                            "Allow"
                            )

                            $path = ($DFSPath + $SAMAccountName)
                            $HomeDir = New-Item -Path $DFSPath -Name $SAMAccountName -ItemType Directory
                            Write-Output "Home Directory created: $($HomeDir.FullName)"

                            $acl = (Get-Item $path).GetAccessControl('Access')

                            $rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $rule_parameters

                            $acl.SetAccessRule($rule)

                            $acl | Set-Acl $path
                    }

                Invoke-Command -ComputerName $Config.DomainDC -ScriptBlock $scriptblock -Credential $Cred -ArgumentList $SAMAccountName, $Config, $DFSPath

            }

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
            Set-ADUser -Identity $newUser -Add @{Description = 'TESTUSER'}
            }
        Get-PSSession | Remove-PSSession
        }

        elseif ($SharedMailbox) {
            $newUserParams = @{
                Name              = "$DisplayName"
                Enabled           = $true
                SamAccountName    = $SAMAccountName
                DisplayName       = "$DisplayName"
                AccountPassword   = (ConvertTo-SecureString -String $Password -AsPlainText -Force) 
                Path              = $Config.CustomerOUDN
                UserPrincipalName = $PrimarySmtpAddress
                EmailAddress      = $PrimarySmtpAddress
                Server            = $Config.DomainFQDN
                PasswordNeverExpires = $true
                PassThru          = $null
            }

            $newUser = New-ADUser @newUserParams -Credential $Cred
        }

        if ($Config.AADsynced -eq 'true') {
            Start-Dirsync -Organization $Organization -Policy 'delta'
            Write-Output "Directory sync has been initiated, because the customer has Office365."
        }
    }
        
}