function New-Tenant {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$PrimarySmtpAddress,

        [Parameter(Mandatory)]
        [ValidateSet("AdvoPlus","Member2015","Legal")]
        [string]$Product,

        [Parameter(Mandatory)]
        [string]$FileServer,

        [Parameter(Mandatory)]
        [string]$FileServerDriveLetter
    )

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2.0

    # Check for missing Windows features.
    $features = @(Get-WindowsFeature 'RSAT-AD-PowerShell', 'RSAT-DFS-Mgmt-Con', 'GPMC')
    if ($features.Count -ne 3) {
        Write-Error "Not all WindowsFeatures were found on this computer."
    }
    
    $featuresMissing = @($features | where Installed -eq $false)
    if ($featuresMissing.Count -ne 0) {
        foreach ($feature in $featuresMissing) {
            Write-Error "Missing feature '$($feature.DisplayName)'." -ErrorAction Continue
        }
        return
    }

    [pscredential]$RemoteCredential = Get-RemoteCredentials -CPO

    $Config = New-TenantConfig -BlankConfig

    if ($PrimarySmtpAddress -match '@') {
        Write-Error "PrimarySmtpAddress must not contain '@'."
    }
        $params = @{
            Name                  = $Name
            PrimarySmtpAddress    = $PrimarySmtpAddress
            FileServer            = $FileServer
            FileServerDriveLetter = $FileServerDriveLetter
            Product               = $Product
        }

    # Exchange commands needed to create tenant.
    $exchangeCommands = @(
        "Get-EmailAddressPolicy", 
        "Get-AddressList", 
        "Get-OfflineAddressBook", 
        "Get-AddressBookPolicy",
        "New-AcceptedDomain",
        "New-EmailAddressPolicy",
        "New-GlobalAddressList",
        "New-AddressList",
        "New-OfflineAddressBook",
        "New-AddressBookPolicy"
    )

    Import-Module (New-ExchangeProxyModule -Command $exchangeCommands)

    $Config = New-TenantConfig @params

    if ($VerbosePreference -eq 'Continue') {
        $Config
    }

    # Check if any Exchange configuration already exists.
    Write-Verbose "Checking for existing Exchange configuration..."
    $conflictingDomains = Get-TenantAcceptedDomain -DomainName $Config.PrimarySmtpAddress
    $existingDomains    = Get-TenantAcceptedDomain -TenantName "$($Config.Name)"  -ErrorAction SilentlyContinue
    $existingEaps       = Get-EmailAddressPolicy   -Identity   "$($Config.Name)*"  -ErrorAction SilentlyContinue
    $existingLists      = Get-AddressList          -SearchText "$($Config.Name) "  -ErrorAction SilentlyContinue # Yes, there's a space at the end
    $existingOab        = Get-OfflineAddressBook   -Identity   "$($Config.Name)*"  -ErrorAction SilentlyContinue
    $existingAbp        = Get-AddressBookPolicy    -Identity   "$($Config.Name)*"  -ErrorAction SilentlyContinue

    if ($conflictingDomains) {
        Write-Error "PrimartySmtpAddress '$($Config.PrimarySmtpAddress)' conflicts with existing accepted domain."
    }
    if ($existingDomains) {
        Write-Error "AcceptedDomain with the name '$($Config.Name)' already exists."
    }
    if ($existingEaps) {
        Write-Error "EmailAddressPolicy with the name '$($Config.Name)' already exists."
    }
    if ($existingLists) {
        Write-Error "AddressList with the name '$($Config.Name)' already exists."
    }
    if ($existingOab) {
        Write-Error "OfflineAddressBook with the name '$($Config.Name)' already exists."
    }
    if ($existingAbp) {
        Write-Error "EmailAddressPolicy with the name '$($Config.Name)' already exists."
    }

    if (-not (Test-Path -Path $Config.DataFilePath)) {
        Write-Error "DataFilePath '$($Config.DataFilePath)' was not found."
    }

    # Set product in config.
    switch ($Product) {
        "AdvoPlus" {
            $productRoleGroup = $Config.AdvoPlusRoleGroupName
            $productGpoName   = $Config.TemplateAdvoPlusGpoName
        }
        "Member2015" {
            $productRoleGroup = $Config.Member2015RoleGroupName
            $productGpoName   = $Config.TemplateMember2015GpoName
        }
        "Legal" {
            $productRoleGroup = $Config.LegalRoleGroupName
            $productGpoName   = $Config.TemplateLegalGpoName
        }
        Default {
            Write-Error "Unknown product '$Product'."
        }
    }

    # Create GPO from template.
    Write-Verbose "Creating GPO '$($Config.NewCustomerGpoName)' from '$($productGpoName)'..."
    $newGpo = Get-GPO -Name $productGpoName -Domain $Config.DomainFQDN | Copy-GPO -TargetName $Config.NewCustomerGpoName -CopyAcl -TargetDomain $Config.DomainFQDN -SourceDomain $Config.DomainFQDN

    # Create OUs.
    foreach ($ou in $Config.OUs) {
        Write-Verbose "Creating OU '$($ou.Name)'."
        New-ADOrganizationalUnit -Name $ou.Name -Path $ou.Path -ProtectedFromAccidentalDeletion $false -Server $Config.DomainFQDN
    }

    # Wait for all OUs to be replicated.
    foreach ($ou in $Config.OUs) {
        Wait-ADReplication -DistinguishedName ("OU={0},{1}" -f $ou.Name, $ou.Path) -Domain $Config.DomainFQDN        
    }

    # Set tenant configuration
    Set-TenantConfig -TenantName $Name -FileServer $Config.FileServer.Name -FileServerDriveLetter $FileServerDriveLetter -Product $Product


    # Set UPN on tenant OU.
    Write-Verbose "Setting UPN suffix '$($Config.PrimarySmtpAddress)' for Users OU."
    Get-ADOrganizationalUnit -Identity $Config.UsersOU -Server $Config.DomainFQDN | Set-ADOrganizationalUnit -Add @{uPNSuffixes="$($Config.PrimarySmtpAddress)"}

    # Create groups.
    Write-Verbose 'Creating AD groups...'
    foreach ($group in $Config.Groups) {
        New-ADGroup -Name $group.Name  -SamAccountName $group.SamAccountName -GroupCategory $group.GroupCategory -GroupScope $group.GroupScope -Path $group.Path -Server $Config.DomainFQDN
    }

    # Wait for all groups to be replicated.
    foreach ($group in $Config.Groups) {
        Wait-ADReplication -SAMAccountName $group.SamAccountName -Domain $Config.DomainFQDN
    }

    # Set AD permissinos for tenant OU.
    Write-Verbose "Adding '$($Config.ReadAccessGroupName)' with ListChildren, ListObject, ReadProperty to '$($Config.NewCustomerOU)'."
    $readAccesGroup = Get-ADGroup -Identity $Config.ReadAccessGroupName -Server $Config.DomainFQDN
    Add-ADAclEntry -ObjectType All -TargetOrganizationalUnit $Config.NewCustomerOU -SecurityIdentifier $readAccesGroup.SID -AccessControlType Allow -Rights ListChildren, ListObject, ReadProperty -Inheritance All

    # Set tenant group memberships.
    foreach ($group in $Config.GroupMembership) {
        Write-Verbose "Adding members to group '$($group.Name)'."
        Add-ADGroupMember -Identity $group.Name -Members $group.MembersToAdd -Server $Config.DomainFQDN
    }
    
    # Add product role group to tenant user role group.
    Write-Verbose "Adding group '$($Config.UserRoleGroupName)' to '$($productRoleGroup)'."
    Add-ADGroupMember -Identity $productRoleGroup -Members $Config.UserRoleGroupName -Server $Config.DomainFQDN

    # Ensure GPO has been replicated before we continue.
    Wait-ADReplication -GPOGuid $newGpo.Id -DomainName $Config.DomainFQDN

    # Set GPO permissions.
    Write-Verbose "Setting 'GpoApply' on GPO '$($Config.NewCustomerGpoName)' for group '$($Config.UserRoleGroupName)'."
    $newGpo | Set-GPPermission -PermissionLevel GpoApply -TargetName $Config.UserRoleGroupName -TargetType Group -Domain $Config.DomainFQDN | Out-Null
    Write-Verbose "Setting 'GpoApply' on GPO '$($Config.NewCustomerGpoName)' for group '$($Config.BaseRdsRoleGroupName)'."
    $newGpo | Set-GPPermission -PermissionLevel GpoApply -TargetName $Config.BaseRdsRoleGroupName -TargetType Group -Domain $Config.DomainFQDN | Out-Null

    # Set GPO links.
    Write-Verbose "Linking GPO '$($Config.NewCustomerGpoName)' to OU '$($Config.UsersOU)'."
    $newGpo | New-GPLink -Target $Config.UsersOU -Domain $Config.DomainFQDN | Out-Null
    
    # Replace placeholder values in GP Preferences settings in GPO.
    $Config.NewCustomerGpoUncPath = Join-Path $Config.PoliciesUncPath "{$($newGpo.Id)}"
    $Config.Fdeploy1UncPath       = Join-Path $Config.NewCustomerGpoUncPath 'User\Documents & Settings\fdeploy1.ini'
    $Config.PreferencesUncPath    = Join-Path $Config.NewCustomerGpoUncPath 'User\Preferences'
    Write-Verbose "NewCustomerGpoUncPath: $($Config.NewCustomerGpoUncPath)"

    $xmlFiles = Get-ChildItem -Path $Config.PreferencesUncPath -Filter '*.xml' -Recurse

    $publicGroup   = Get-ADGroup -Filter "Name -eq '$($Config.PublicAccessGroupName)'" -Server $Config.DomainFQDN
    $userRoleGroup = Get-ADGroup -Filter "Name -eq '$($Config.UserRoleGroupName)'"     -Server $Config.DomainFQDN

    foreach ($file in $xmlFiles) {
        Write-Verbose "Replacing template placeholders in file '$($file.Name)'."
        $content = Get-Content -Path $file.FullName
    
        for ($i = 0; $i -lt $content.Length; $i++) {
            $content[$i] = $content[$i].Replace('[Template-Initials]', $Config.Name)
            $content[$i] = $content[$i].Replace('[Template-PublicFileAccessSid]', $publicGroup.SID.Value)
            $content[$i] = $content[$i].Replace('[Template-UserRoleSid]', $userRoleGroup.SID.Value)
        }

        Set-Content -Value $content -Path $file.FullName -Encoding UTF8 # Preferences XML files uses UTF-8 by default.
    }

    # Replace placeholder values in redirected folders GPO.
    Write-Verbose "Retrieving redirected folders from '$($Config.Fdeploy1UncPath)'."
    $fdeploy1 = Get-Content $Config.Fdeploy1UncPath
    for ($i = 0; $i -lt $fdeploy1.Length; $i++) {
        $fdeploy1[$i] = $fdeploy1[$i].Replace('[Template-Initials]', $Config.Name.ToLower())
    }

    Write-Verbose "Saving changes to '$($Config.Fdeploy1UncPath)'."
    $fdeploy1 | Set-Content -Path $Config.Fdeploy1UncPath -Encoding Ascii # fdeploy1.ini uses ANSI by default.

    # Create folders for user profile data and shares.
    foreach ($folder in $Config.Folders) {
        Write-Verbose "Creating folder '$($folder.Name)' in '$($folder.Path)'"
        $newFolder = New-Item -ItemType Directory -Name $folder.Name -Path $folder.Path

        foreach ($permission in $folder.Permissions) {
            $adObject = Get-ADObject -Filter "SAMAccountName -eq '$($permission.IdentityReference.Value)'" -Properties objectSid -Server $Config.DomainFQDN

            $params = @{
                FileSystemRights  = $permission.FileSystemRights -split ', '
                AccessControlType = $permission.AccessControlType
                SecurityIdentifier= $adObject.objectSid
                InheritanceFlags  = $permission.InheritanceFlags -split ', '
                PropagationFlags  = $permission.PropagationFlags -split ', '
                Path              = $newFolder.FullName 
            }

            Add-AclEntry @params
        }
    }

    # Create SMB shares.
    foreach ($share in $Config.Shares) {
        Write-Verbose "Creating share '$($share.Name)' with local path '$($share.Path)' on computer '$($Config.FileServer.Fqdn)'"
        New-SmbShare -Name $share.Name -Path $share.Path -FullAccess 'Everyone' -CimSession "$($Config.FileServer.Fqdn)" | Out-Null
    }
    
    # Create DFS shares through PowerShell Endpoint.
    try {
        $dfsnError = $null
        $dfsnModule = Import-PSSession (New-PSSession -ComputerName $Config.SelfServicePSEndpoint -ConfigurationName 'Selfservice' -Name 'SelfServiceEndpoint')

        foreach ($dfsFolder in $Config.DfsFolders) {
            Write-Verbose "Creating DFS folder '$($dfsFolder.Path)' with target path '$($dfsFolder.TargetPath)'"
            New-DfsnFolder -Path $dfsFolder.Path -TargetPath $dfsFolder.TargetPath -CimSession (Get-ADDomainController -Domain $Config.DomainFQDN -Discover).HostName | Out-Null

            foreach ($account in $dfsFolder.Accounts) {
                Write-Verbose "Granting access for '$account' on '$($dfsFolder.Path)'"
                Grant-DfsnAccess -Path $dfsFolder.Path -AccountName $account | Out-Null
            }
        }
    }
    catch {
        $dfsnError = $_
    }
    finally {
        $dfsnModule | Remove-Module
        Remove-PSSession -Name 'SelfServiceEndpoint'
    }

    if ($dfsnError) {
        Write-Error $dfsnError
    }

    # Create Exchange organization.
    New-AcceptedDomain –Name $Config.Name –DomainName $Config.PrimarySmtpAddress –DomainType Authoritative | Out-Null
    New-EmailAddressPolicy -Name $Config.Name -IncludedRecipients "AllRecipients" -ConditionalCustomAttribute1 $Config.Name -RecipientContainer $Config.UsersOU -EnabledEmailAddressTemplates "SMTP:%m@$($Config.PrimarySmtpAddress)" | Out-Null

    New-GlobalAddressList -Name $Config.Name -RecipientContainer $Config.NewCustomerOU -RecipientFilter "((Alias -ne '`$NULL') -and (CustomAttribute1 -eq '$($Config.Name)'))" | Out-Null
    New-AddressList -Name "$($Config.Name) All Users" -Container "\" -DisplayName "All Users" -RecipientFilter "((Alias -ne '`$NULL') -and (objectClass -eq 'user') -and (CustomAttribute1 -eq '$($Config.Name)'))" | Out-Null
    New-AddressList -Name "$($Config.Name) Room List" -Container "\" -DisplayName "Room List" | Out-Null
    New-OfflineAddressBook –Name $Config.Name -AddressLists "\$($Config.Name)" | Out-Null

    New-AddressBookPolicy –Name $Config.Name –GlobalAddressList "\$($Config.Name)" –OfflineAddressBook "\$($Config.Name)" –AddressLists "\$($Config.Name) All Users" -RoomList "\$($Config.Name) Room List" | Out-Null

    # Create Capto support user
    $supportUserParams = @{
        TenantName = $Config.Name 
        Password   = [guid]::NewGuid().Guid 
        FirstName  = $Config.SupportUser.Firstname 
        LastName   = $Config.SupportUser.Lastname 
        TestUser   = $true
        PrimarySmtpAddress = $Config.SupportUser.UserPrincipalName 
    }

    New-TenantUser @supportUserParams
    ###

    # Create mail migration user
    $mailMigrationUserParams = @{
        TenantName = $Config.Name 
        Password   = $Config.MailMigrationUser.Password
        FirstName  = $Config.MailMigrationUser.Firstname
        LastName   = $Config.MailMigrationUser.Lastname
        TestUser   = $true
        PrimarySmtpAddress = $Config.MailMigrationUser.UserPrincipalName
    }

    New-TenantUser @mailMigrationUserParams
    ###

    if ($Product -eq 'AdvoPlus') {
        # Create AdvoPlus service account.
        $svcpassword = [guid]::NewGuid().Guid
        $serviceAccount = New-Object System.Management.Automation.PSCredential ("$($Config.DomainNetbiosName)\$($Config.ServiceAccount.Name)", (ConvertTo-SecureString $svcpassword -AsPlainText -Force))

        Write-Verbose "Creating AdvoPlus service account $($Config.ServiceAccount.UserPrincipalName)..."
        New-TenantUser -TenantName $Config.Name -ServiceAccount -Password $svcpassword -PasswordNeverExpires $true -UserPrincipalName $Config.ServiceAccount.UserPrincipalName -Product $Product

        Write-Verbose "Adding $($Config.ServiceAccount.Name) SPN to $($Config.RepositoryServer.Name)"
            Get-ADComputer -Identity $Config.RepositoryServer.Name -Server $Config.DomainFQDN | Set-ADComputer -Add @{"msDS-AllowedToDelegateTo"=@("http/$($Config.Name)", "http/$($Config.Name).hosting.capto.dk")}

        # Create program folder for AdvoPlus service
        $advofolderparams = @{
            TenantName  = $Config.Name
            Source      = Join-Path $Config.NAVInstanceServer.ServiceUncPath $Config.NAVInstanceServer.ServiceTemplateName
            Destination = Join-Path $Config.NAVInstanceServer.ServiceUncPath $Config.Name
        }
        New-AdvoPlusServiceProgramFolder @advofolderparams

        # Configure AdvoPlus service
        $advoserviceparams = @{
            TenantName       = $Config.Name
            Path             = Join-Path $Config.NAVInstanceServer.ServiceFolderPath $Config.Name
            DatabaseServer   = $Config.DatabaseServer.Name
            DatabaseName     = $Config.Name
            ServerInstance   = $Config.Name
            RepositoryServer = $Config.RepositoryServer.Name
            Domain           = $Config.DomainFQDN
            ServiceAccount   = $serviceAccount
            ComputerName     = $Config.NAVInstanceServer.Fqdn
        }
        New-AdvoPlusService @advoserviceparams

        # Create DNS record for tenant
        $dnsDc = (Get-ADDomainController -DomainName $Config.DomainFQDN -Discover).HostName
        $repIp = (Resolve-DnsName -Name $Config.NAVInstanceServer.Fqdn)[0].IPAddress
        Write-Verbose "Adding DNS A record '$($Config.Name)' with IP '$repIp' on DNS server '$dnsDc'..."
        Add-DnsServerResourceRecordA -ComputerName $dnsDc -ZoneName $Config.DomainFQDN -IPv4Address $repIp -Name $Config.Name
    }
    elseif ($Product -eq "Member2015") {
        # Create Member service account.
        $svcpassword = [guid]::NewGuid().Guid
        $serviceAccount = New-Object System.Management.Automation.PSCredential ("$($Config.DomainNetbiosName)\$($Config.ServiceAccount.Name)", (ConvertTo-SecureString $svcpassword -AsPlainText -Force))

        Write-Verbose "Creating Member service account $($Config.ServiceAccount.UserPrincipalName)..."
        New-MemberServiceAccount -TenantName $Config.Name -Name $Config.ServiceAccount.Name -UserPrincipalName $Config.ServiceAccount.UserPrincipalName -Password $svcpassword

        Write-Verbose "Creating Member NAV service '$($Config.Name)' on '$($Config.NAVInstanceServer.Fqdn)'"
        New-MemberService -TenantName $Config.Name -DatabaseServer $Config.DatabaseServer.Name -DatabaseName $Config.Name -ServerInstance $Config.Name -ServiceAccount $serviceAccount -ComputerName $Config.NAVInstanceServer.Fqdn

        Write-Verbose "Creating Member NAV client service '$($Config.Name)Client' on '$($Config.NAVInstanceServer.Fqdn)'"
        New-MemberService -TenantName $Config.Name -DatabaseServer $Config.DatabaseServer.Name -DatabaseName $Config.Name -ServerInstance "$($Config.Name)Client" -ServiceAccount $serviceAccount -ComputerName $Config.NAVInstanceServer.Fqdn -CredentialType UserName -CertificateThumbprint '2E326EB707DF615AF10F76BB89AE56496FDC954B'
    }
    elseif ($Product -eq 'Legal') {
        
        # Create Legal service account.
        $svcpassword = [guid]::NewGuid().Guid
        $serviceAccount = New-Object System.Management.Automation.PSCredential ("$($Config.DomainNetbiosName)\$($Config.ServiceAccount.Name)", (ConvertTo-SecureString $svcpassword -AsPlainText -Force))

        Write-Verbose "Creating Legal service account $($Config.ServiceAccount.UserPrincipalName)..."
        New-TenantUser -TenantName $Config.Name -ServiceAccount -Password $svcpassword -PasswordNeverExpires $true -UserPrincipalName $Config.ServiceAccount.UserPrincipalName -Product $Product

        ## Set AD rights (Full allow on self), on SVC account
        $aclBlock = {
            param(
            [string]$Name,
            [pscredential]$Serviceaccount
            )
            $SysManObj = [ADSI]("LDAP://CN=$($Name)_NAV_SVC,OU=ServiceAccounts,OU=$($Name),OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk")
            $Account = New-Object System.Security.Principal.NTAccount($Serviceaccount.UserName)
            $ActiveDirectoryRights = "GenericAll"
            $AccessControlType = "Allow"
            $Inherit = "SelfAndChildren"
            $nullGUID = [guid]'00000000-0000-0000-0000-000000000000'
            $ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $Account, $ActiveDirectoryRights, $AccessControlType, $Inherit, $nullGUID
            $SysManObj.psbase.ObjectSecurity.AddAccessRule($ACE)
            $SysManObj.psbase.commitchanges()
        }
        Invoke-Command -ComputerName $Config.SelfServicePSEndpoint -ScriptBlock $aclBlock -Credential $RemoteCredential -ArgumentList $Name, $Serviceaccount


        Write-Verbose "Adding $($Config.ServiceAccount.Name) SPN to $($Config.RepositoryServer.Name)"
            Get-ADComputer -Identity $Config.RepositoryServer.Name -Server $Config.DomainFQDN | Set-ADComputer -Add @{"msDS-AllowedToDelegateTo"=@("http/$($Config.Name)", "http/$($Config.Name).hosting.capto.dk")}

         # Configure Legal service
        Write-Verbose "TEST - New-Legalservice PARAMS"
        $Legalserviceparams = @{
            TenantName       = $Config.Name
            Path             = Join-Path $Config.NAVInstanceServer.ServiceFolderPath $Config.Name
            DatabaseServer   = $Config.DatabaseServer.Name
            DatabaseName     = $Config.Name
            ServerInstance   = $Config.Name
            RepositoryServer = $Config.RepositoryServer.Name
            Domain           = $Config.DomainFQDN
            ServiceAccount   = $serviceAccount
            ComputerName     = $Config.NAVInstanceServer.Fqdn
        }

        New-LegalService2016 @Legalserviceparams

        # Create DNS record for tenant
        $dnsDc = (Get-ADDomainController -DomainName $Config.DomainFQDN -Discover).HostName
        $repIp = (Resolve-DnsName -Name $Config.NAVInstanceServer.Fqdn)[0].IPAddress
        Write-Verbose "Adding DNS A record '$($Config.Name)' with IP '$repIp' on DNS server '$dnsDc'..."
        Add-DnsServerResourceRecordA -ComputerName $dnsDc -ZoneName $Config.DomainFQDN -IPv4Address $repIp -Name $Config.Name
        
        # Create Config file for Legal customers..

        $xmlTemplate = Get-ChildItem -Path "\\hosting.capto.dk\data\systemhosting\TemplateFiles\ClientUserSettings.config" -Filter '*.config' -Recurse
        foreach($file in $xmlTemplate){
            Copy-Item -Path $file.PSPath -Destination ($config.CapLegalConfigFilePath + "\" + $config.CapLegalConfigFileName) -Force

            $XMLTenant = Get-ChildItem -Path $config.CapLegalConfigFilePath -Filter '*.config' -Recurse

            foreach ($Newfile in $XMLTenant) {
                Write-Verbose "Replacing template placeholders in file '$($Newfile.Name)'."
                $content = Get-Content -Path $Newfile.FullName
    
                for ($i = 0; $i -lt $content.Length; $i++) {
                    $content[$i] = $content[$i].Replace('[Template-Initials]', $Config.Name)
                }

                Set-Content -Value $content -Path $Newfile.FullName -Encoding UTF8
                }
          }
    }


    # Set quotas
    $localTenantDataPath = Resolve-UncPath -Path $Config.NewCustomerDataFilePath
    try {
        New-FsrmQuota -Path $localTenantDataPath -Template 'Default' -CimSession $Config.FileServer.Fqdn | Out-Null
    }
    catch {
        Write-Error "Unable to set quota on path '$localTenantDataPath': $_"
    }
    ###

    # Create AdvoPlus SQL DB
    if ($Product -eq 'AdvoPlus') {
        New-TenantDatabase -TenantName $Config.Name -ComputerName $Config.DatabaseServer.Fqdn
    }
    else{
        Write-Verbose "Product not AdvoPlus, no need to create DB.."
        }
    ###
}