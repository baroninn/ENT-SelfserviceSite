function New-TenantAccount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Organization,

        [Parameter(Mandatory)]
        [string]$AccountName,

        [Parameter(Mandatory)]
        [string]$Shortname
    )

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2.0

    $Config = Get-TenantConfig -TenantName $Organization
    $RemoteCredential = Get-RemoteCredentials -CPO

    if ($Config.Product.Name -eq 'AdvoPlus') {
        # Create AdvoPlus service account.
        $svcpassword = [guid]::NewGuid().Guid
        $serviceAccount = New-Object System.Management.Automation.PSCredential ("$($Config.DomainNetbiosName)\$($Config.ServiceAccount.Name)_$Shortname", (ConvertTo-SecureString $svcpassword -AsPlainText -Force))

        Write-Verbose "Creating AdvoPlus service account $($Config.ServiceAccount.Name)_$Shortname@$($Config.PrimarySmtpAddress)..."
        $SPN = @("http/$($Organization.ToUpper())_$Shortname", "http/$($Organization.ToUpper())_$Shortname.hosting.capto.dk")
        New-TenantUser -TenantName $Config.Name -ServiceAccount -Password $svcpassword -PasswordNeverExpires $true -UserPrincipalName ("$($Config.ServiceAccount.Name)_$Shortname@$($Config.PrimarySmtpAddress)").Replace("$($config.Name)_","") -Product $Config.Product.Name -SPN $SPN

        ## Set AD rights (Full allow on self), on SVC account
        $Name = $Config.Name
        $Account = "$($Config.ServiceAccount.Name)_$Shortname"
        $aclBlock = {
            param(
            [string]$Organization,
            [string]$Account,
            [pscredential]$Serviceaccount
            )
            $SysManObj = [ADSI]("LDAP://CN=$Account,OU=ServiceAccounts,OU=$($Organization),OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk")
            $AccountNT = New-Object System.Security.Principal.NTAccount($Serviceaccount.UserName)
            $ActiveDirectoryRights = "GenericAll"
            $AccessControlType = "Allow"
            $Inherit = "SelfAndChildren"
            $nullGUID = [guid]'00000000-0000-0000-0000-000000000000'
            $ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $AccountNT, $ActiveDirectoryRights, $AccessControlType, $Inherit, $nullGUID
            $SysManObj.psbase.ObjectSecurity.AddAccessRule($ACE)
            $SysManObj.psbase.commitchanges()
        }
        Invoke-Command -ComputerName $Config.SelfServicePSEndpoint -ScriptBlock $aclBlock -Credential $RemoteCredential -ArgumentList $Organization, $Account, $serviceAccount


        Write-Verbose "Adding $Account SPN to $($Config.RepositoryServer.Name)"
           Get-ADComputer -Identity $Config.RepositoryServer.Name -Server $Config.DomainFQDN | Set-ADComputer -Add @{"msDS-AllowedToDelegateTo"=@("http/$($Organization)_$Shortname", "http/$($Organization)_$Shortname.hosting.capto.dk")}


        # Create program folder for AdvoPlus service
        $advofolderparams = @{
            TenantName  = $Config.Name
            Source      = Join-Path $Config.NAVInstanceServer.ServiceUncPath $Config.NAVInstanceServer.ServiceTemplateName
            Destination = Join-Path $Config.NAVInstanceServer.ServiceUncPath "$($Config.Name)_$Shortname"
        }
        New-AdvoPlusServiceProgramFolder @advofolderparams

        # Configure AdvoPlus service
        $advoserviceparams = @{
            TenantName       = $Config.Name
            Path             = Join-Path $Config.NAVInstanceServer.ServiceFolderPath "$($Config.Name)_$Shortname"
            DatabaseServer   = $Config.DatabaseServer.Name
            DatabaseName     = $Config.Name
            ServerInstance   = "$($Config.Name)_$Shortname"
            RepositoryServer = $Config.RepositoryServer.Name
            Domain           = $Config.DomainFQDN
            ServiceAccount   = $serviceAccount
            ComputerName     = $Config.NAVInstanceServer.Fqdn
        }
        New-AdvoPlusService @advoserviceparams

        $webserviceParams = @{
            TenantName  = "$($Config.Name)_$Shortname"
            CompanyName = $AccountName 
            WebServicePath    = $Config.RepositoryServer.WebServicePath 
            WebServiceLogPath = $Config.RepositoryServer.WebServiceLogPath 
            LogWriter    = (Get-ADGroup -Server $Config.DomainFQDN -Identity $Config.AdvoPlusRepoLogsGroupName).SID
            ComputerName = $Config.RepositoryServer.Fqdn
        }

        try {
            New-AdvoPlusWebServiceInstance @webserviceParams
        }
        catch {
            Write-Error $_.ToString()
        }

        try {
            New-AdvoPlusMobileServerInstance -TenantName $Config.Name -CompanyName $AccountName -ComputerName $Config.MobileServer.Fqdn
        }
        catch {
            Write-Error $_.ToString()
        }

        ## Try to change/add GPO settings..
        $Group = Get-ADGroup "$($config.Name)_Access_$Shortname" -Server $Config.DomainFQDN

        $GPO = Get-GPO -Name $Config.NewCustomerGpoName -Domain $Config.DomainFQDN

        $GPOPath = Join-Path $Config.PoliciesUncPath "{$($Gpo.Id)}"
        $Config.PreferencesUncPath    = Join-Path $GPOPath 'User\Preferences'

        $Shortcuts = Get-ChildItem -Path $Config.PreferencesUncPath -Filter 'Shortcuts.xml' -Recurse
        $Registry = Get-ChildItem -Path $Config.PreferencesUncPath -Filter 'Registry.xml' -Recurse
        $shortcutcontent = Get-Content -Path $Shortcuts.FullName
        $registrycontent = Get-Content -Path $Registry.FullName

        ## Change XML data

$shortcutTEMP = @"
<Shortcut clsid="{4F2F7C55-2790-433e-8127-0739D1CFA327}" name="_name" status="_status" image="2" changed="2015-10-21 12:31:46" uid="_uid" userContext="1" bypassErrors="1"><Properties pidl="" targetType="FILESYSTEM" action="U" comment="" shortcutKey="0" startIn="%AppDataDir%" arguments="_arguments" iconIndex="0" targetPath="C:\Program Files (x86)\Microsoft Dynamics NAV\60\Classic\finsql.exe" iconPath="C:\Program Files (x86)\Microsoft Dynamics NAV\60\Classic\finsql.exe" window="" shortcutPath="_shortcutpath"/><Filters><FilterGroup bool="AND" not="0" name="_filtername" sid="_filtersid" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Shortcut>
</Shortcuts>
"@

        $shortcutDATA = $shortcutTEMP -replace "_name", "$Accountname"
        $shortcutDATA = $shortcutDATA -replace "_status", "$Accountname"
        $shortcutDATA = $shortcutDATA -replace "_uid", ('{' + [guid]::NewGuid().ToString() + '}')
        $shortcutDATA = $shortcutDATA -replace "_arguments", ("servername=$($Config.DatabaseServer.Name),database=$($Config.Name),NTAuthentication=1,Company='" + ("$Accountname") + "'")
        $shortcutDATA = $shortcutDATA -replace "_shortcutpath", "%DesktopDir%\$Accountname"
        $shortcutDATA = $shortcutDATA -replace '_filtername', "CAPTO\$($Group.SamAccountName)"
        $shortcutDATA = $shortcutDATA -replace "_filtersid", $Group.SID

$registryTEMP = @"

	<Collection clsid="{53B533F5-224C-47e3-B01B-CA3B3F3FF4BF}" name="_collectionname"><Registry clsid="{9CD4B2F4-923D-47f5-A062-E897DD1DAD50}" name="BaseAddress" status="BaseAddress" image="7" changed="2017-03-15 15:27:23" uid="_uid" bypassErrors="1"><Properties action="U" displayDecimal="0" default="0" hive="HKEY_CURRENT_USER" key="SOFTWARE\Wow6432Node\Capto\Advo\Repository" name="BaseAddress" type="REG_SZ" value="_BaseAddressregvalue"/><Filters><FilterGroup bool="AND" not="0" name="_filtername" sid="_filtersid" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Registry>
            <Registry clsid="{9CD4B2F4-923D-47f5-A062-E897DD1DAD50}" name="NavBaseAddress" status="NavBaseAddress" image="7" changed="2017-03-15 15:27:23" uid="_uid" bypassErrors="1"><Properties action="U" displayDecimal="0" default="0" hive="HKEY_CURRENT_USER" key="SOFTWARE\Wow6432Node\Capto\Advo\Repository" name="NavBaseAddress" type="REG_SZ" value="_NavBaseAddressregvalue"/><Filters><FilterGroup bool="AND" not="0" name="_filtername" sid="_filtersid" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Registry>
            <Registry clsid="{9CD4B2F4-923D-47f5-A062-E897DD1DAD50}" name="NavSpn" status="NavSpn" image="7" changed="2017-03-15 15:27:23" uid="_uid" bypassErrors="1"><Properties action="U" displayDecimal="0" default="0" hive="HKEY_CURRENT_USER" key="SOFTWARE\Wow6432Node\Capto\Advo\Repository" name="NavSpn" type="REG_SZ" value="_NavSpnValue"/><Filters><FilterGroup bool="AND" not="0" name="_filtername" sid="_filtersid" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Registry>
            <Registry clsid="{9CD4B2F4-923D-47f5-A062-E897DD1DAD50}" name="NTLM" status="NTLM" image="12" changed="2017-03-15 15:27:23" uid="_uid" bypassErrors="1"><Properties action="U" displayDecimal="0" default="0" hive="HKEY_CURRENT_USER" key="SOFTWARE\Wow6432Node\Capto\Advo\Repository" name="NTLM" type="REG_DWORD" value="00000001"/><Filters><FilterGroup bool="AND" not="0" name="_filtername" sid="_filtersid" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Registry>
	</Collection>
</RegistrySettings>
"@

        $registryDATA = $registryTEMP -replace "_collectionname", "NAV_$Shortname"
        $registryDATA = $registryDATA -replace "_uid", ('{' + [guid]::NewGuid().ToString() + '}')
        $registryDATA = $registryDATA -replace "_BaseAddressregvalue", "http://$($Config.RepositoryServer.Name):81/$($Organization)_$($Shortname)"
        $registryDATA = $registryDATA -replace "_NavBaseAddressregvalue", "http://$($Organization)_$($Shortname):7047/$($Organization)_$($Shortname)/WS/$AccountName"
        $registryDATA = $registryDATA -replace "_NavSpnValue", "http/$($Organization)_$($Shortname)"
        $registryDATA = $registryDATA -replace "_shortcutpath", "%DesktopDir%\$Accountname"
        $registryDATA = $registryDATA -replace '_filtername', "CAPTO\$($Group.SamAccountName)"
        $registryDATA = $registryDATA -replace "_filtersid", $Group.SID


        $shortcutcontent -replace "</Shortcuts>", $shortcutDATA | Set-Content -Path $Shortcuts.FullName -Encoding UTF8
        $registrycontent -replace "</RegistrySettings>", $registryDATA | Set-Content -Path $Registry.FullName -Encoding UTF8

    }
    elseif ($Config.Product.Name -eq 'Legal') {
        
        # Create Legal service account.
        $svcpassword = [guid]::NewGuid().Guid
        $serviceAccount = New-Object System.Management.Automation.PSCredential ("$($Config.DomainNetbiosName)\$($Config.ServiceAccount.Name)_$Shortname", (ConvertTo-SecureString $svcpassword -AsPlainText -Force))

        Write-Verbose "Creating Legal service account $($Config.ServiceAccount.Name)_$Shortname@$($Config.PrimarySmtpAddress)..."

        $SPN = @("http/$($Organization.ToUpper())_$Shortname", "http/$($Organization.ToUpper())_$Shortname.hosting.capto.dk")
        New-TenantUser -TenantName $Config.Name -ServiceAccount -Password $svcpassword -PasswordNeverExpires $true -UserPrincipalName ("$($Config.ServiceAccount.Name)_$Shortname@$($Config.PrimarySmtpAddress)").Replace("$($config.Name)_","") -Product $Config.Product.Name -SPN $SPN

        ## Set AD rights (Full allow on self), on SVC account
        $Name = $Config.Name
        $Account = "$($Config.ServiceAccount.Name)_$Shortname"
        $aclBlock = {
            param(
            [string]$Organization,
            [string]$Account,
            [pscredential]$Serviceaccount
            )
            $SysManObj = [ADSI]("LDAP://CN=$Account,OU=ServiceAccounts,OU=$($Organization),OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk")
            $AccountNT = New-Object System.Security.Principal.NTAccount($Serviceaccount.UserName)
            $ActiveDirectoryRights = "GenericAll"
            $AccessControlType = "Allow"
            $Inherit = "SelfAndChildren"
            $nullGUID = [guid]'00000000-0000-0000-0000-000000000000'
            $ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $AccountNT, $ActiveDirectoryRights, $AccessControlType, $Inherit, $nullGUID
            $SysManObj.psbase.ObjectSecurity.AddAccessRule($ACE)
            $SysManObj.psbase.commitchanges()
        }
        Invoke-Command -ComputerName $Config.SelfServicePSEndpoint -ScriptBlock $aclBlock -Credential $RemoteCredential -ArgumentList $Organization, $Account, $serviceAccount


        Write-Verbose "Adding $Account SPN to $($Config.RepositoryServer.Name)"
           Get-ADComputer -Identity $Config.RepositoryServer.Name -Server $Config.DomainFQDN | Set-ADComputer -Add @{"msDS-AllowedToDelegateTo"=@("http/$($Organization)_$Shortname", "http/$($Organization)_$Shortname.hosting.capto.dk")}

         # Configure Legal service
        Write-Verbose "TEST - New-Legalservice PARAMS"
        $Legalserviceparams = @{
            TenantName       = $Config.Name
            Path             = Join-Path $Config.NAVInstanceServer.ServiceFolderPath "$($Config.Name)_$Shortname"
            DatabaseServer   = $Config.DatabaseServer.Name
            DatabaseName     = $Config.Name
            ServerInstance   = "$($Config.Name)_$Shortname"
            RepositoryServer = $Config.RepositoryServer.Name
            Domain           = $Config.DomainFQDN
            ServiceAccount   = $serviceAccount
            SkipDBCreation   = $true
            ComputerName     = $Config.NAVInstanceServer.Fqdn
        }

        New-LegalService2016 @Legalserviceparams

        $webserviceParams = @{
            TenantName  = "$($Config.Name)_$Shortname"
            CompanyName = $AccountName 
            WebServicePath    = $Config.RepositoryServer.WebServicePath 
            WebServiceLogPath = $Config.RepositoryServer.WebServiceLogPath 
            LogWriter    = (Get-ADGroup -Server $Config.DomainFQDN -Identity $Config.LegalRepoLogsGroupName).SID
            ComputerName = $Config.RepositoryServer.Fqdn
        }

        try {
            New-LegalWebServiceInstance @webserviceParams
        }
        catch {
            Write-Error "$_"
        }

        try {
            New-LegalMobileServerInstance -TenantName "$($Config.Name)_$Shortname" -CompanyName $AccountName -ComputerName $Config.MobileServer.Fqdn
        }
        catch {
            Write-Error $_.ToString()
        }

        try {
            New-ADGroup -Name "$($config.Name)_Access_$Shortname" -GroupCategory Security -GroupScope DomainLocal -Path $Config.AccessGroupsOU -Server $Config.DomainFQDN
        }
        catch {
            Write-Error "$_"
        }

        ## Try to change/add GPO settings..
        $Group = Get-ADGroup "$($config.Name)_Access_$Shortname" -Server $Config.DomainFQDN

        $GPO = Get-GPO -Name $Config.NewCustomerGpoName -Domain $Config.DomainFQDN

        $GPOPath = Join-Path $Config.PoliciesUncPath "{$($Gpo.Id)}"
        $Config.PreferencesUncPath    = Join-Path $GPOPath 'User\Preferences'

        $Shortcuts = Get-ChildItem -Path $Config.PreferencesUncPath -Filter 'Shortcuts.xml' -Recurse
        $Registry = Get-ChildItem -Path $Config.PreferencesUncPath -Filter 'Registry.xml' -Recurse
        $shortcutcontent = Get-Content -Path $Shortcuts.FullName
        $registrycontent = Get-Content -Path $Registry.FullName

        ## Change XML data

$shortcutTEMP = @"
<Shortcut clsid="{4F2F7C55-2790-433e-8127-0739D1CFA327}" name="_name" status="_status" image="2" changed="2015-10-21 12:31:46" uid="_uid" userContext="1" bypassErrors="1"><Properties pidl="" targetType="FILESYSTEM" action="U" comment="" shortcutKey="0" startIn="%AppDataDir%" arguments="_arguments" iconIndex="0" targetPath="C:\Program Files (x86)\Microsoft Dynamics NAV\90\RoleTailored Client\Microsoft.Dynamics.Nav.Client.exe" iconPath="C:\Program Files (x86)\Microsoft Dynamics NAV\90\RoleTailored Client\Microsoft.Dynamics.Nav.Client.exe" window="" shortcutPath="_shortcutpath"/><Filters><FilterGroup bool="AND" not="0" name="_filtername" sid="_filtersid" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Shortcut>
</Shortcuts>
"@

        $shortcutDATA = $shortcutTEMP -replace "_name", "$Accountname"
        $shortcutDATA = $shortcutDATA -replace "_status", "$Accountname"
        $shortcutDATA = $shortcutDATA -replace "_uid", ('{' + [guid]::NewGuid().ToString() + '}')
        $shortcutDATA = $shortcutDATA -replace "_arguments", ('-settings:&quot;' + "H:\Config\ClientUserSettings_$($Shortname).config" + '&quot;')
        $shortcutDATA = $shortcutDATA -replace "_shortcutpath", "%DesktopDir%\$Accountname"
        $shortcutDATA = $shortcutDATA -replace '_filtername', "CAPTO\$($Group.SamAccountName)"
        $shortcutDATA = $shortcutDATA -replace "_filtersid", $Group.SID

$registryTEMP = @"

	<Collection clsid="{53B533F5-224C-47e3-B01B-CA3B3F3FF4BF}" name="_collectionname"><Registry clsid="{9CD4B2F4-923D-47f5-A062-E897DD1DAD50}" name="BaseAddress" status="BaseAddress" image="7" changed="2017-03-15 15:27:23" uid="_uid" bypassErrors="1"><Properties action="U" displayDecimal="0" default="0" hive="HKEY_CURRENT_USER" key="SOFTWARE\Wow6432Node\Capto\Advo\Repository" name="BaseAddress" type="REG_SZ" value="_BaseAddressregvalue"/><Filters><FilterGroup bool="AND" not="0" name="_filtername" sid="_filtersid" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Registry>
            <Registry clsid="{9CD4B2F4-923D-47f5-A062-E897DD1DAD50}" name="NavBaseAddress" status="NavBaseAddress" image="7" changed="2017-03-15 15:27:23" uid="_uid" bypassErrors="1"><Properties action="U" displayDecimal="0" default="0" hive="HKEY_CURRENT_USER" key="SOFTWARE\Wow6432Node\Capto\Advo\Repository" name="NavBaseAddress" type="REG_SZ" value="_NavBaseAddressregvalue"/><Filters><FilterGroup bool="AND" not="0" name="_filtername" sid="_filtersid" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Registry>
            <Registry clsid="{9CD4B2F4-923D-47f5-A062-E897DD1DAD50}" name="NavSpn" status="NavSpn" image="7" changed="2017-03-15 15:27:23" uid="_uid" bypassErrors="1"><Properties action="U" displayDecimal="0" default="0" hive="HKEY_CURRENT_USER" key="SOFTWARE\Wow6432Node\Capto\Advo\Repository" name="NavSpn" type="REG_SZ" value="_NavSpnValue"/><Filters><FilterGroup bool="AND" not="0" name="_filtername" sid="_filtersid" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Registry>
            <Registry clsid="{9CD4B2F4-923D-47f5-A062-E897DD1DAD50}" name="NTLM" status="NTLM" image="12" changed="2017-03-15 15:27:23" uid="_uid" bypassErrors="1"><Properties action="U" displayDecimal="0" default="0" hive="HKEY_CURRENT_USER" key="SOFTWARE\Wow6432Node\Capto\Advo\Repository" name="NTLM" type="REG_DWORD" value="00000001"/><Filters><FilterGroup bool="AND" not="0" name="_filtername" sid="_filtersid" userContext="1" primaryGroup="0" localGroup="0"/></Filters></Registry>
	</Collection>
</RegistrySettings>
"@

        $registryDATA = $registryTEMP -replace "_collectionname", "NAV_$Shortname"
        $registryDATA = $registryDATA -replace "_uid", ('{' + [guid]::NewGuid().ToString() + '}')
        $registryDATA = $registryDATA -replace "_BaseAddressregvalue", "http://$($Config.RepositoryServer.Name):81/$($Organization)_$($Shortname)"
        $registryDATA = $registryDATA -replace "_NavBaseAddressregvalue", "http://$($Organization)_$($Shortname):7047/$($Organization)_$($Shortname)/WS/$AccountName"
        $registryDATA = $registryDATA -replace "_NavSpnValue", "http/$($Organization)_$($Shortname)"
        $registryDATA = $registryDATA -replace "_shortcutpath", "%DesktopDir%\$Accountname"
        $registryDATA = $registryDATA -replace '_filtername', "CAPTO\$($Group.SamAccountName)"
        $registryDATA = $registryDATA -replace "_filtersid", $Group.SID


        $shortcutcontent -replace "</Shortcuts>", $shortcutDATA | Set-Content -Path $Shortcuts.FullName -Encoding UTF8
        $registrycontent -replace "</RegistrySettings>", $registryDATA | Set-Content -Path $Registry.FullName -Encoding UTF8


        # Create Config file for new Account..
        $xmlTemplate = Get-ChildItem -Path "\\hosting.capto.dk\data\systemhosting\TemplateFiles" -Filter 'ClientUserSettings_Extra.config' -Recurse
        $newAccountFile = $config.CapLegalConfigFileName -replace "ClientUserSettings", "ClientUserSettings_$($Shortname)"
        foreach($file in $xmlTemplate){
            Copy-Item -Path $file.PSPath -Destination ($config.CapLegalConfigFilePath + "\" + "$newAccountFile") -Force

            $XMLTenant = Get-ChildItem -Path $config.CapLegalConfigFilePath -Filter $newAccountFile -Recurse

            foreach ($Newfile in $XMLTenant) {
                Write-Verbose "Replacing template placeholders in file '$($Newfile.Name)'."
                $content = Get-Content -Path $Newfile.FullName
    
                for ($i = 0; $i -lt $content.Length; $i++) {
                    $content[$i] = $content[$i].Replace('[Template-Server]', "$($Config.Name)_$Shortname")
                    $content[$i] = $content[$i].Replace('[Template-ServerInstance]', "$($Config.Name)_$Shortname")
                    $content[$i] = $content[$i].Replace('[Template-Shortname]', "$($Config.Name)_$Shortname")
                }

                Set-Content -Value $content -Path $Newfile.FullName -Encoding UTF8
                }
          }

    }
}