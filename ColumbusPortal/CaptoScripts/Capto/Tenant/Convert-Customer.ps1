function Convert-Customer {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Organization
    )

    $ErrorActionPreference = "Stop"
    Set-StrictMode -Version 2

    $Config = Get-TenantConfig -TenantName $Organization

    $json = (Get-ADOrganizationalUnit -Server $Config.DomainFQDN -Identity "OU=$Organization,OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk" -Properties adminDescription).adminDescription
    $obj = ConvertFrom-Json -InputObject $json

    Set-TenantConfig -TenantName $Organization -FileServer $obj.FileServer.Name -FileServerDriveLetter $obj.FileServer.DriveLetter -Product "Legal"

    [pscredential]$RemoteCredential = Get-RemoteCredentials -CPO

    $NewConfig = Get-TenantConfig -TenantName $Organization 

    $OldproductRoleGroup = $Config.AdvoPlusRoleGroupName
    $OldproductGpoName   = ($Config.Name + "_GPO_RDS_Default")
    $productRoleGroup    = $NewConfig.LegalRoleGroupName
    $productGpoName      = $NewConfig.TemplateLegalGpoName

    # Create GPO from template.
    Write-Verbose "Converting GPO '$($NewConfig.NewCustomerGpoName)' from '$($OldproductGpoName)'..."
    $oldGpo = Get-GPO -all -Domain $Config.DomainFQDN | where{$_.DisplayName -like $OldproductGpoName}
    $oldGpo | Rename-GPO -TargetName ($oldGpo.DisplayName + "_OLD") -Domain $Config.DomainFQDN
    $newGpo = Get-GPO -Name $productGpoName -Domain $Config.DomainFQDN | Copy-GPO -TargetName ($NewConfig.NewCustomerGpoName) -CopyAcl -TargetDomain $NewConfig.DomainFQDN -SourceDomain $NewConfig.DomainFQDN

    # Ensure GPO has been replicated before we continue.
    Wait-ADReplication -GPOGuid $newGpo.Id -DomainName $Config.DomainFQDN

    # Set GPO permissions.
    Write-Verbose "Setting 'GpoApply' on GPO '$($NewConfig.NewCustomerGpoName)' for group '$($NewConfig.UserRoleGroupName)'."
    $newGpo | Set-GPPermission -PermissionLevel GpoApply -TargetName $Config.UserRoleGroupName -TargetType Group -Domain $NewConfig.DomainFQDN | Out-Null
    Write-Verbose "Setting 'GpoApply' on GPO '$($Config.NewCustomerGpoName)' for group '$($Config.BaseRdsRoleGroupName)'."
    $newGpo | Set-GPPermission -PermissionLevel GpoApply -TargetName $NewConfig.BaseRdsRoleGroupName -TargetType Group -Domain $NewConfig.DomainFQDN | Out-Null

    # Replace placeholder values in GP Preferences settings in GPO.
    $NewConfig.NewCustomerGpoUncPath = Join-Path $NewConfig.PoliciesUncPath "{$($newGpo.Id)}"
    $NewConfig.Fdeploy1UncPath       = Join-Path $NewConfig.NewCustomerGpoUncPath 'User\Documents & Settings\fdeploy1.ini'
    $NewConfig.PreferencesUncPath    = Join-Path $NewConfig.NewCustomerGpoUncPath 'User\Preferences'
    Write-Verbose "NewCustomerGpoUncPath: $($NewConfig.NewCustomerGpoUncPath)"

    $xmlFiles = Get-ChildItem -Path $NewConfig.PreferencesUncPath -Filter '*.xml' -Recurse

    $publicGroup   = Get-ADGroup -Filter "Name -eq '$($NewConfig.PublicAccessGroupName)'" -Server $NewConfig.DomainFQDN
    $userRoleGroup = Get-ADGroup -Filter "Name -eq '$($NewConfig.UserRoleGroupName)'"     -Server $NewConfig.DomainFQDN

    foreach ($file in $xmlFiles) {
        Write-Verbose "Replacing template placeholders in file '$($file.Name)'."
        $content = Get-Content -Path $file.FullName
    
        for ($i = 0; $i -lt $content.Length; $i++) {
            $content[$i] = $content[$i].Replace('[Template-Initials]', $NewConfig.Name)
            $content[$i] = $content[$i].Replace('[Template-PublicFileAccessSid]', $publicGroup.SID.Value)
            $content[$i] = $content[$i].Replace('[Template-UserRoleSid]', $userRoleGroup.SID.Value)
        }

        Set-Content -Value $content -Path $file.FullName -Encoding UTF8 # Preferences XML files uses UTF-8 by default.
    }

    # Replace placeholder values in redirected folders GPO.
    Write-Verbose "Retrieving redirected folders from '$($NewConfig.Fdeploy1UncPath)'."
    $fdeploy1 = Get-Content $NewConfig.Fdeploy1UncPath
    for ($i = 0; $i -lt $fdeploy1.Length; $i++) {
        $fdeploy1[$i] = $fdeploy1[$i].Replace('[Template-Initials]', $NewConfig.Name.ToLower())
    }

    Write-Verbose "Saving changes to '$($NewConfig.Fdeploy1UncPath)'."
    $fdeploy1 | Set-Content -Path $NewConfig.Fdeploy1UncPath -Encoding Ascii # fdeploy1.ini uses ANSI by default.

    foreach ($group in $NewConfig.Groups) {
        try{
        $groupexist = Get-ADGroup -identity $group.Name -Server $NewConfig.DomainFQDN
        }catch{
                $groupexist = $null}

            if($groupexist) {
                Write-Verbose "Group exists.."}
            else{
                New-ADGroup -Name $group.Name -SamAccountName $group.SamAccountName -GroupCategory $group.GroupCategory -GroupScope $group.GroupScope -Path $group.Path -Server $NewConfig.DomainFQDN
            }
        }

    $LogWriter = (Get-ADGroup -Server $Config.DomainFQDN -Identity $Config.AdvoPlusRepoLogsGroupName).SID
    Remove-ADGroup -Identity $Config.AdvoPlusRepoLogsGroupName -Server $Config.DomainFQDN -Confirm:$false

    # Set tenant group memberships.
    foreach ($group in $NewConfig.GroupMembership) {
        Write-Verbose "Adding members to group '$($group.Name)'."
        Add-ADGroupMember -Identity $group.Name -Members $group.MembersToAdd -Server $NewConfig.DomainFQDN
        }
        # Add product role group to tenant user role group.
        Write-Verbose "Adding group '$($NewConfig.UserRoleGroupName)' to '$($productRoleGroup)'."
        Add-ADGroupMember -Identity $productRoleGroup -Members $NewConfig.UserRoleGroupName -Server $NewConfig.DomainFQDN
        Remove-ADGroupMember -Identity $OldproductRoleGroup -Members $Config.UserRoleGroupName -Server $NewConfig.DomainFQDN -Confirm:$false

    # Create CapLegal folders
    New-Item -ItemType Directory -Name $NewConfig.CapLegalDocFolderName     -Path $NewConfig.CapLegalDataFilePath
    New-Item -ItemType Directory -Name $NewConfig.CapLegalConfigFolderName  -Path $NewConfig.PublicDataFilePath

    # Remove present service account
    Remove-ADUser -Identity ($NewConfig.Name + "_NAV_SVC") -Server $Config.DomainFQDN -Confirm:$false

    # Create Legal service account.
    $svcpassword = [guid]::NewGuid().Guid
    $serviceAccount = New-Object System.Management.Automation.PSCredential ("$($NewConfig.DomainNetbiosName)\$($NewConfig.ServiceAccount.Name)", (ConvertTo-SecureString $svcpassword -AsPlainText -Force))

    Write-Verbose "Creating Legal service account $($Config.ServiceAccount.UserPrincipalName)..."
    New-TenantUser -TenantName $NewConfig.Name -ServiceAccount -Password $svcpassword -PasswordNeverExpires $true -UserPrincipalName $NewConfig.ServiceAccount.UserPrincipalName -Product $NewConfig.Product.Name
    
    ## Set AD rights (Full allow on self), on SVC account
        $aclBlock = {
            param(
            [string]$Organization,
            [pscredential]$Serviceaccount
            )
            $SysManObj = [ADSI]("LDAP://CN=$($Organization)_NAV_SVC,OU=ServiceAccounts,OU=$($Organization),OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk")
            $Account = New-Object System.Security.Principal.NTAccount($Serviceaccount.UserName)
            $ActiveDirectoryRights = "GenericAll"
            $AccessControlType = "Allow"
            $Inherit = "SelfAndChildren"
            $nullGUID = [guid]'00000000-0000-0000-0000-000000000000'
            $ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $Account, $ActiveDirectoryRights, $AccessControlType, $Inherit, $nullGUID
            $SysManObj.psbase.ObjectSecurity.AddAccessRule($ACE)
            $SysManObj.psbase.commitchanges()
        }
    Invoke-Command -ComputerName $Config.SelfServicePSEndpoint -ScriptBlock $aclBlock -Credential $RemoteCredential -ArgumentList $Organization, $Serviceaccount


    Write-Verbose "Adding $($NewConfig.ServiceAccount.Name) SPN to $($NewConfig.RepositoryServer.Name)"
        Get-ADComputer -Identity $NewConfig.RepositoryServer.Name -Server $NewConfig.DomainFQDN | Set-ADComputer -Add @{"msDS-AllowedToDelegateTo"=@("http/$($NewConfig.Name)", "http/$($NewConfig.Name).hosting.capto.dk")}

    # Configure Legal service
    Write-Verbose "TEST - New-Legalservice PARAMS"

    $Legalserviceparams = @{
        TenantName       = $NewConfig.Name
        Path             = Join-Path $NewConfig.NAVInstanceServer.ServiceFolderPath $NewConfig.Name
        DatabaseServer   = $NewConfig.DatabaseServer.Name
        DatabaseName     = $NewConfig.Name
        ServerInstance   = $NewConfig.Name
        RepositoryServer = $NewConfig.RepositoryServer.Name
        Domain           = $NewConfig.DomainFQDN
        ServiceAccount   = $serviceAccount
        ComputerName     = $NewConfig.NAVInstanceServer.Fqdn
    }

    New-LegalService2016 @Legalserviceparams

    # Create NAV DNS record for tenant
    $dnsDc = (Get-ADDomainController -DomainName $NewConfig.DomainFQDN -Discover).HostName
    $repIp = (Resolve-DnsName -Name $NewConfig.NAVInstanceServer.Fqdn)[0].IPAddress
    $oldrepIp = (Resolve-DnsName -Name $Config.NAVInstanceServer.Fqdn)[0].IPAddress

    Remove-DnsServerResourceRecord -ComputerName $dnsDc -ZoneName $Config.DomainFQDN -RecordData $oldrepIp -RRType A -Name $Config.Name -Force -Confirm:$false
    Add-DnsServerResourceRecordA -ComputerName $dnsDc -ZoneName $NewConfig.DomainFQDN -IPv4Address $repIp -Name $NewConfig.Name
        
    # Create Config file for Legal customers..

    Write-Verbose "Creating NAV 2016 settings file in $($NewConfig.CapLegalConfigFilePath)"
    $xmlTemplate = Get-ChildItem -Path "\\hosting.capto.dk\data\systemhosting\TemplateFiles\ClientUserSettings.config" -Filter '*.config' -Recurse
    foreach($file in $xmlTemplate){
        Copy-Item -Path $file.PSPath -Destination "$($NewConfig.CapLegalConfigFilePath)\$($NewConfig.CapLegalConfigFileName)" -Force

        $XMLTenant = Get-ChildItem -Path $NewConfig.CapLegalConfigFilePath -Filter '*.config' -Recurse

        foreach ($Newfile in $XMLTenant) {
            Write-Verbose "Replacing template placeholders in file '$($Newfile.Name)'."
            $content = Get-Content -Path $Newfile.FullName
    
            for ($i = 0; $i -lt $content.Length; $i++) {
                $content[$i] = $content[$i].Replace('[Template-Initials]', $NewConfig.Name)
            }

            Set-Content -Value $content -Path $Newfile.FullName -Encoding UTF8 # Preferences XML files uses UTF-8 by default.
        }
    }

    # Remove AdvoPlus services..

    if ($Config.Product.Name -eq "AdvoPlus") {
        $webserviceParams = @{
            TenantName  = $Config.Name
            CompanyName = 'Remove' 
            WebServicePath    = $Config.RepositoryServer.WebServicePath 
            WebServiceLogPath = $Config.RepositoryServer.WebServiceLogPath 
            LogWriter    = $Config.Name
            ComputerName = $Config.RepositoryServer.Fqdn
            Remove       = $True
        }

        try {
            New-AdvoPlusWebServiceInstance @webserviceParams
        }
        catch {
            Write-Error ($_)
        }

        try {
            New-AdvoPlusMobileServerInstance -TenantName $Config.Name -CompanyName 'Remove' -ComputerName $Config.MobileServer.Fqdn -Remove $True
        }
        catch {
            Write-Error ($_)
        }
        
        
        Write-Verbose "Trying to remove Service and files on CPO-NST-01.."

            $NSTblock = {
                param($Organization)

                sc.exe delete ("MicrosoftDynamicsNavWS$" + $Organization)
                sc.exe stop ("MicrosoftDynamicsNavWS$" + $Organization)
                try {
                    Start-Sleep 5
                    $Item = Get-Item "C:\Program Files (x86)\Microsoft Dynamics NAV\60\Service\$Organization" -ErrorAction stop
                    $Item | Remove-Item -Recurse -Force -ErrorAction Stop                     
                }
                catch {
                }

            }

        try {
            Invoke-Command -ComputerName $Config.NAVInstanceServer.Fqdn -ScriptBlock $NSTblock -Credential $RemoteCredential -ArgumentList $Organization -Authentication Credssp
        }
        catch {
            #Get-Item "\\$($Config.NAVInstanceServer.Fqdn)\C$\Program Files (x86)\Microsoft Dynamics NAV\60\Service\$Organization" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            Write-Output "Removal of NAV Service on $($Config.NAVInstanceServer.Fqdn) failed with error: $_"
        }
        try{
            Remove-AdvoPlusWindowsFirewallRules -TenantName $Organization -ComputerName $Config.NAVInstanceServer.Fqdn
        }
        catch{
            Write-Error ($_)
        }
    }
}