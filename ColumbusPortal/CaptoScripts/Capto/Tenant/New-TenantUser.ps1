function New-TenantUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Password,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]$PasswordNeverExpires,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet("AdvoPlus", "Member2015", "Legal")]
        [string]$Product,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [string]$PrimarySmtpAddress,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [string]$FirstName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [string]$LastName,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [string[]]$EmailAlias,
        
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [bool]$TestUser,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [bool]$StudJur,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [bool]$MailOnly,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="ServiceAccount")]
        [switch]$ServiceAccount,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="ServiceAccount")]
        [string]$UserPrincipalName,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName="ServiceAccount")]
        [string[]]$SPN = @("http/$($TenantName.ToUpper())", "http/$($TenantName.ToUpper()).hosting.capto.dk")
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Import-Module (New-ExchangeProxyModule -Command "Get-Mailbox", "Enable-Mailbox", "Set-Mailbox", "Update-Recipient", "Add-MailboxPermission")
    }
    Process {
        $TenantName = $TenantName.ToUpper()

        if ($ServiceAccount) {
            $PrimarySmtpAddress = $UserPrincipalName
        }

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

        $Config = Get-TenantConfig -TenantName $TenantName

        try {
            $ou = Get-ADOrganizationalUnit -Identity $Config.UsersOU -Server $Config.DomainFQDN
        }
        catch {
            Write-Error "The tenant '$TenantName' was not found."
        }

        $tenantDomains = @(Get-TenantAcceptedDomain -TenantName $TenantName)
        if (-not ($tenantDomains.Where{$_.DomainName -eq "$domain"})) {
            Write-Error "Domain '$domain' was not found for the tenant '$TenantName'."
        }

        # SAMAccountName must be 20 chars or less.
        $SAMAccountName = ("{0}_{1}" -f $TenantName, $alias)
        if ($SAMAccountName.Length -gt 20) {
            $SAMAccountName = $SAMAccountName.Substring(0, 19)
        }

        Write-Verbose "SAMAccountName: $SAMAccountName"

        $newUserParams = @{
            Name              = if ($ServiceAccount) { $SAMAccountName } else { "$FirstName $LastName" }
            Enabled           = $true
            SamAccountName    = $SAMAccountName
            DisplayName       = if ($ServiceAccount) { $SAMAccountName } else { "$FirstName $LastName" }
            AccountPassword   = (ConvertTo-SecureString -String $Password -AsPlainText -Force) 
            Path              = if ($ServiceAccount) { $Config.ServiceAccountsOU } else { $Config.UsersOU }
            UserPrincipalName = $PrimarySmtpAddress
            GivenName         = if ($ServiceAccount) { $SAMAccountName } else { $FirstName }
            Surname           = $LastName
            Server            = $Config.DomainFQDN
            PassThru          = $null
        }
        $setMailboxParams = @{
            Identity          = $SAMAccountName
            CustomAttribute1  = "$TenantName"
            AddressBookPolicy = "$TenantName"
            EmailAddressPolicyEnabled     = $false
            HiddenFromAddressListsEnabled = $TestUser
        }

        if ($PasswordNeverExpires) {
            $newUserParams.Add("PasswordNeverExpires", $true)
        }
        if ($TestUser) {
            $setMailboxParams.Add("CustomAttribute2", "TestUser")
        }

        $newUser = New-ADUser @newUserParams
        
        Wait-ADReplication -DistinguishedName $newUser.DistinguishedName -DomainName $Config.DomainFQDN

        if ($ServiceAccount) {

            Add-ADGroupMember –Identity "$($Config.Name)_Role_ServiceAccount" –Members $newUser -Server $Config.DomainFQDN

            if($Product -eq "Legal"){
                Write-verbose "LegalTest - Making service account member of Base_Access_CPO-NST-05_WCF_ServiceAccounts.."
                Add-ADGroupMember -Identity "Base_Access_CPO-NST-05_WCF_ServiceAccounts" -Members $newUser -Server $Config.DomainFQDN
                Add-ADGroupMember -Identity "$($Config.Name)_Access_File_Public" -Members $newUser -Server $Config.DomainFQDN

                $newUser | Set-ADUser -Add @{
                    servicePrincipalName = $SPN
                    "msDS-AllowedToDelegateTo" = @(
                        "cifs/CPO-AD-01"
                        "cifs/CPO-AD-01/CAPTO"
                        "cifs/CPO-AD-01.hosting.capto.dk"
                        "cifs/CPO-AD-01.hosting.capto.dk/CAPTO"
                        "cifs/CPO-AD-01.hosting.capto.dk/hosting.capto.dk"
                        "cifs/CPO-AD-02"
                        "cifs/CPO-AD-02/CAPTO"
                        "cifs/CPO-AD-02.hosting.capto.dk"
                        "cifs/CPO-AD-02.hosting.capto.dk/CAPTO"
                        "cifs/CPO-AD-02.hosting.capto.dk/hosting.capto.dk"
                        "cifs/CPO-FILE-01"
                        "cifs/CPO-FILE-01.hosting.capto.dk"
                        "cifs/CPO-FILE-02"
                        "cifs/CPO-FILE-02.hosting.capto.dk"
                        "http/CPO-REP-01"
                        "http/CPO-REP-01.hosting.capto.dk"
                        "HOST/CPO-REP-01"
                        "HOST/CPO-REP-01.hosting.capto.dk"
                        "http/CPO-REP-02"
                        "http/CPO-REP-02.hosting.capto.dk"
                        "HOST/CPO-REP-02"
                        "HOST/CPO-REP-02.hosting.capto.dk"
                        "MSSQLSvc/CPO-SQL-03.hosting.capto.dk:1433"
                        "DynamicsNAV/$($Config.Name).hosting.capto.dk:7045"
                        "DynamicsNAV/$($Config.Name).hosting.capto.dk:7046"
                        "DynamicsNAV/$($Config.Name):7045"
                        "DynamicsNAV/$($Config.Name):7046"

                    )
                }
            }
           if($Product -eq "AdvoPlus"){

                $newUser | Set-ADUser -Add @{
                    servicePrincipalName = $SPN
                    "msDS-AllowedToDelegateTo" = @(
                        "cifs/CPO-AD-01"
                        "cifs/CPO-AD-01/CAPTO"
                        "cifs/CPO-AD-01.hosting.capto.dk"
                        "cifs/CPO-AD-01.hosting.capto.dk/CAPTO"
                        "cifs/CPO-AD-01.hosting.capto.dk/hosting.capto.dk"
                        "cifs/CPO-AD-02"
                        "cifs/CPO-AD-02/CAPTO"
                        "cifs/CPO-AD-02.hosting.capto.dk"
                        "cifs/CPO-AD-02.hosting.capto.dk/CAPTO"
                        "cifs/CPO-AD-02.hosting.capto.dk/hosting.capto.dk"
                        "cifs/CPO-FILE-01"
                        "cifs/CPO-FILE-01.hosting.capto.dk"
                        "cifs/CPO-FILE-02"
                        "cifs/CPO-FILE-02.hosting.capto.dk"
                        "http/CPO-REP-01"
                        "http/CPO-REP-01.hosting.capto.dk"
                        "HOST/CPO-REP-01"
                        "HOST/CPO-REP-01.hosting.capto.dk"
                        "http/CPO-REP-02"
                        "http/CPO-REP-02.hosting.capto.dk"
                        "HOST/CPO-REP-02"
                        "HOST/CPO-REP-02.hosting.capto.dk"
                        "MSSQLSvc/CPO-SQL-01.hosting.capto.dk:1433"
                    )
                }
            }

            Set-ADUser -Identity $newUser -Server $Config.DomainFQDN -Add @{extensionAttribute11="User_DoNotSync"}
        }
        else {
            Add-ADGroupMember –Identity $Config.AllDistributionGroupName -Members $newUser -Server $Config.DomainFQDN

            if ($MailOnly) {
                Add-ADGroupMember –Identity $Config.MailOnlyRoleGroupName -Members $newUser -Server $Config.DomainFQDN
            }
            else {
                # Everyone but MailOnly users are members of the user role group
                Add-ADGroupMember –Identity $Config.UserRoleGroupName -Members $newUser -Server $Config.DomainFQDN
            }
            
            if ($StudJur) {
                Add-ADGroupMember –Identity $Config.StudJurRoleGroupName –Members $newUser -Server $Config.DomainFQDN
            }

            if ($Config.Product.Name -eq "Legal" -and $Config.TenantID365.ID -ne "43eea929-d726-4742-83a9-603c12a0d195") {
                Set-ADUser -Identity $newUser -Server $Config.DomainFQDN -Add @{extensionAttribute11="User_DoNotSync"}
            }
            
            if ($Config.Product.Name -eq "AdvoPlus" -or $Config.Product.Name -eq "Member2015") {
                Set-ADUser -Identity $newUser -Server $Config.DomainFQDN -Add @{extensionAttribute11="User_DoNotSync"}
            }

            $newMbx = Enable-Mailbox -Identity $SAMAccountName –PrimarySMTPAddress $PrimarySmtpAddress
            if ($newMbx) {
                Set-Mailbox @setMailboxParams
                Update-Recipient –Identity $SAMAccountName
            }
            else {
                Write-Error "Error enabling mailbox for '$($SAMAccountName)'."
            }

            Write-Verbose "Creating folder '$($SAMAccountName)' in '$($Config.FoldersDfsUncPath)'."
            $newUserFolder = New-Item -ItemType Directory -Name $SAMAccountName.ToLower() -Path $Config.FoldersDfsUncPath

            $sid = New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $newUser.SID
            Add-AclEntry -FileSystemRights Modify -AccessControlType Allow -InheritanceFlags ContainerInherit,ObjectInherit -PropagationFlags None -SecurityIdentifier $sid -Path $newUserFolder.FullName

            foreach ($folder in $Config.NewUser.RedirectedFolders) {
                $newFolder = Join-Path $newUserFolder.FullName $folder
                Write-Verbose "Creating '$newFolder'..."
                New-Item -ItemType Directory -Path $newFolder | Out-Null
            }

            if ($EmailAlias) {
                foreach ($extraAlias in $EmailAlias) {
                    Write-Verbose "Adding alias '$($extraAlias)'."
                    $newMbx.EmailAddresses.Add($extraAlias) | Out-Null
                }

                Set-Mailbox -Identity $SAMAccountName -EmailAddresses $newMbx.EmailAddresses
            }

            if (-not $TestUser) {
                Set-TenantMailboxPlan -TenantName $Config.Name -Name $SAMAccountName -MailboxPlan 10GB
                Write-Verbose "Setting 'FullAccess' permissions on '$($SAMAccountName)' for '$($Config.MailMigrationUser.UserPrincipalName)'..."
                Add-MailboxPermission -Identity $SAMAccountName -User $Config.MailMigrationUser.UserPrincipalName -AccessRights FullAccess -ErrorAction 'SilentlyContinue' | Out-Null
                $localTenantDataPath = Resolve-UncPath -Path $Config.NewCustomerDataFilePath
                try {
                    Write-Verbose "Getting quota for '$localTenantDataPath' on '$($Config.FileServer.Fqdn)'..."
                    $quota = Get-FsrmQuota -Path $localTenantDataPath -CimSession $Config.FileServer.Fqdn -ErrorAction SilentlyContinue
                    if ($quota.Size -lt 5GB) {
                        $newQuotaSize = 5GB
                    } 
                    else {
                        $newQuotaSize = $quota.Size + 5GB
                    }
                    
                    Write-Verbose "Setting new quota size to '$($newQuotaSize)'..."
                    $quota | Set-FsrmQuota -Size $newQuotaSize | Out-Null
                    
                }
                catch {
                    Write-Verbose "Skipping quota on '$localTenantDataPath' because an error occurred"
                    #Write-Error "Unable to get quota on path '$localTenantDataPath'"
                }
            }

            Set-TenantUser -TenantName $TenantName -Name $newMbx.DistinguishedName -ExcludeFromMailboxAutoResize $false
        }
    }
}