function New-TenantConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   ParameterSetName='Config')]
        [string]
        $Name,

        [Parameter(Mandatory=$true,
                   ParameterSetName='Config')]
        [string]
        $PrimarySmtpAddress,

        [Parameter(Mandatory=$true,
                   ParameterSetName='Config')]
        [string]
        $FileServer,

        [Parameter(Mandatory=$true,
                   ParameterSetName='Config')]
        [string]
        $FileServerDriveLetter,

        [Parameter(Mandatory=$false,
                   ParameterSetName='Config')]
        [bool]
        $AdvoPlusGpoSet,

        [bool]
        $LegalGpoSet,

        [string]
        $TenantID,

        [string]
        $TenantAdmin,

        [string]
        $TenantPass,

        [Parameter(Mandatory=$false,
                   ParameterSetName='Config')]
        [ValidateSet("AdvoPlus", "Member2015", "Legal")]
        [string]$Product = "AdvoPlus",

        [Parameter(ParameterSetName='BlankConfig')]
        [switch]
        $BlankConfig
    )

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2.0

    function New-GroupMembershipObject {
        [Cmdletbinding()]
        param (
            [Parameter(Mandatory=$true)]
            [string]
            $Name,

            [Parameter(Mandatory=$true)]
            [string[]]
            $MembersToAdd
        )

        [pscustomobject]@{
            Name         = $Name
            MembersToAdd = @($MembersToAdd)
        }
    }

    function New-FolderObject {
        [Cmdletbinding()]
        param (
            [Parameter(Mandatory=$true)]
            [string]
            $Name,

            [Parameter(Mandatory=$true)]
            [string]
            $Path,

            [System.Security.AccessControl.FileSystemAccessRule[]]
            $Permissions
        )

        [pscustomobject]@{
            Name        = $Name
            Path        = $Path
            Permissions = if ($Permissions) { @($Permissions) } else { $null }
        }
    }

    function New-ShareObject {
        [Cmdletbinding()]
        param (
            [Parameter(Mandatory=$true)]
            [string]
            $Name,

            [Parameter(Mandatory=$true)]
            [string]
            $Path
        )

        [pscustomobject]@{
            Name = $Name
            Path = $Path
        }
    }

    function New-GroupObject {
        [Cmdletbinding()]
        param (
            [Parameter(Mandatory=$true)]
            [string]
            $Name,

            [Parameter(Mandatory=$true)]
            [string]
            $SamAccountName,

            [Parameter(Mandatory=$true)]
            [ValidateSet('Distribution','Security')]
            [string]
            $GroupCategory,

            [Parameter(Mandatory=$true)]
            [ValidateSet('DomainLocal','Global','Universal')]
            [string]
            $GroupScope,

            [Parameter(Mandatory=$true)]
            [string]
            $Path
        )

        [pscustomobject]@{
            Name           = $Name
            SamAccountName = $SamAccountName
            GroupCategory  = $GroupCategory
            GroupScope     = $GroupScope
            Path           = $Path
        }
    }

    function New-OUObject {
        [Cmdletbinding()]
        param (
            [Parameter(Mandatory=$true)]
            [string]
            $Name,

            [Parameter(Mandatory=$true)]
            [string]
            $Path
        )

        [pscustomobject]@{
            Name   = $Name
            Path   = $Path
        }
    }

    function New-DfsFolderObject {
        [Cmdletbinding()]    
        param (
            [Parameter(Mandatory=$true)]
            [string]
            $Path,

            [Parameter(Mandatory=$true)]
            [string]
            $TargetPath,

            [Parameter(Mandatory=$true)]
            [string[]]
            $Accounts
        )

        [pscustomobject]@{
            Path       = $Path
            TargetPath = $TargetPath
            Accounts   = @($Accounts)
        }
    }

    $Config = [pscustomobject]@{
        Name                      = $null
        AllDistributionGroupName  = $null
        CustomerOU                = $null
        NewCustomerOU             = $null
        UsersOU                   = $null
        GroupsOU                  = $null
        ServiceAccountsOU         = $null
        AccessGroupsOU            = $null
        DistributionGroupsOU      = $null
        RolesGroupsOU             = $null
        MailboxGroupsOU           = $null
        PrimarySmtpAddress        = $null
        PublicAccessGroupName     = $null
        PrivateListDirGroupName   = $null
        AdvoPlusRepoLogsGroupName = $null
        LegalRepoLogsGroupName    = $null
        ReadAccessGroupName       = $null
        DfsAdminGroupName         = $null
        AllRoleGroupName          = $null
        UserRoleGroupName         = $null
        SvcAccRoleGroupName       = $null
        BaseUserRoleGroupName     = $null
        BaseRdsRoleGroupName      = $null
        ModifyGroupsGroupName     = $null
        AdvoPlusRoleGroupName     = $null
        Member2015RoleGroupName   = $null
        LegalRoleGroupName        = $null
        StudJurRoleGroupName      = $null
        MailOnlyRoleGroupName     = $null
        GroupMembership           = $null
        DomainFQDN                = $null
        DomainNetbiosName         = $null
        SelfServicePSEndpoint     = $null
        DataFilePath              = $null
        PrivateFolderName         = $null
        FoldersFolderName         = $null
        PublicFolderName          = $null
        AdvoForumFolderName       = $null
        AdvoForumDocFolderName    = $null
        CapLegalFolderName        = $null
        CapLegalDocFolderName     = $null
        CapLegalConfigFolderName  = $null
        CapLegalVersionFolderName = $null
        NewCustomerDataFilePath   = $null
        PrivateDataFilePath       = $null
        FoldersDataFilePath       = $null
        PublicDataFilePath        = $null
        AdvoForumDataFilePath     = $null
        AdvoForumDocDataFilePath  = $null
        CapLegalDataFilePath      = $null
        CapLegalDocDataFilePath   = $null
        CapLegalConfigFilePath    = $null
        CapLegalConfigFileName    = $null
        VersionDataFilePath       = $null
        PrivateShareName          = $null
        PublicShareName           = $null
        VersionShareName          = $null
        PrivateShareUncPath       = $null
        PublicShareUncPath        = $null
        VersionShareUncPath       = $null
        Folders                   = $null
        Files                     = $null
        Groups                    = $null
        OUs                       = $null
        Shares                    = $null
        DfsFolders                = $null
        DataDfsUncPath            = $null
        PrivateDfsUncPath         = $null
        PublicDfsUncPath          = $null
        FoldersDfsUncPath         = $null
        PrivateDfsFolderName      = $null
        PublicDfsFolderName       = $null
        VersionDfsFolderName      = $null
        VersionDfsUncPath         = $null
        TemplateMember2015GpoName = $null
        TemplateAdvoPlusGpoName   = $null
        TemplateLegalGpoName      = $null
        NewCustomerGpoName        = $null
        NewCustomerGpoUncPath     = $null
        PreferencesUncPath        = $null
        PoliciesUncPath           = $null
        Fdeploy1UncPath           = $null
        ServiceAccount = [pscustomobject]@{
            Name              = $null
            UserPrincipalName = $null
        }
        RepositoryServer = [pscustomobject]@{
            Name = $null
            Fqdn = $null
            WebServicePath    = $null
            WebServiceLogPath = $null
        }
        MobileServer = [pscustomobject]@{
            Name = $null
            Fqdn = $null
        }
        NAVInstanceServer = [pscustomobject]@{
            Name = $null
            Fqdn = $null
            ServiceFolderPath   = $null
            ServiceUncPath      = $null
            ServiceTemplateName = $null
        }
        DatabaseServer = [pscustomobject]@{
            Name = $null
            Fqdn = $null
        }
        FileServer = [pscustomobject]@{
            Name     = $null
            Fqdn     = $null
            DataPath = $null
        }
        SupportUser = [pscustomobject]@{
            Firstname = $null
            Lastname  = $null
            UserPrincipalName = $null
        }
        MailMigrationUser = [pscustomobject]@{
            Firstname = $null
            Lastname  = $null
            UserPrincipalName = $null
            Password  = $null
        }
        NewUser = [pscustomobject]@{
            RedirectedFolders = $null
        }
        NativeDatabaseServer = [pscustomobject]@{
            Name = $null
            Fqdn = $null
            Port = $null
            DatabasePath = $null
        }
        GroupPolicy = [pscustomobject]@{
            AdvoPlusNative = [pscustomobject]@{
                Name = $null
            }
        }
        AdvoPlus = [pscustomobject]@{
            GpoSet = $null
        }
        Legal = [pscustomobject]@{
            GpoSet = $null
        }
        Member = [pscustomobject]@{
            PrecreatedServiceAccountsOU = $null
        }
        Product = [pscustomobject]@{
            Name = $null
        }
        TenantID365 = [pscustomobject]@{
            ID    = $null
            Admin = $null
            Pass  = $null
        }
        Certificate = [pscustomobject]@{
            WildcardCapto365Thumbprint = $null
        }
    }

    if ($BlankConfig) {
        return $Config
    }

    Write-Verbose 'Getting configuration info... '
    $Config.Name                      = $Name.ToUpper()
    $Config.AllDistributionGroupName  = "$($Config.Name)_Distribution_All"
    $Config.DomainFQDN                = 'hosting.capto.dk'
    $Config.DomainNetbiosName         = 'capto'
    $Config.SelfServicePSEndpoint     = 'cpo-ad-01.hosting.capto.dk'
    $Config.CustomerOU                = "OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"
    $Config.NewCustomerOU             = "OU=$($Config.Name),OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"
    $Config.UsersOU                   = "OU=Users,OU=$($Config.Name),OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"
    $Config.GroupsOU                  = "OU=Groups,OU=$($Config.Name),OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"
    $Config.ServiceAccountsOU         = "OU=ServiceAccounts,OU=$($Config.Name),OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"
    $Config.AccessGroupsOU            = "OU=Access,OU=Groups,OU=$($Config.Name),OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"
    $Config.DistributionGroupsOU      = "OU=Distribution,OU=Groups,OU=$($Config.Name),OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"
    $Config.RolesGroupsOU             = "OU=Roles,OU=Groups,OU=$($Config.Name),OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"
    $Config.MailboxGroupsOU           = "OU=Mailbox,OU=Groups,OU=$($Config.Name),OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"
    $Config.PrimarySmtpAddress        = $PrimarySmtpAddress
    $Config.DfsAdminGroupName         = 'Base_Access_DFSAdministrator'
    $Config.PublicAccessGroupName     = "$($Config.Name)_Access_File_Public"
    $Config.PrivateListDirGroupName   = "$($Config.Name)_Access_File_Private_ListDirectory"
    $Config.AdvoPlusRepoLogsGroupName = "$($Config.Name)_Access_AdvoPlus_RepositoryLogs"
    $Config.LegalRepoLogsGroupName    = "$($Config.Name)_Access_Legal_RepositoryLogs"
    $Config.ReadAccessGroupName       = "$($Config.Name)_Access_Customer_Read"
    $Config.AllRoleGroupName          = "$($Config.Name)_Role_All"
    $Config.SvcAccRoleGroupName       = "$($Config.Name)_Role_ServiceAccount"
    $Config.UserRoleGroupName         = "$($Config.Name)_Role_User"
    $Config.StudJurRoleGroupName      = "$($Config.Name)_Role_StudJur"
    $Config.MailOnlyRoleGroupName     = "$($Config.Name)_Role_MailOnly"
    $Config.BaseUserRoleGroupName     = "Base_Role_User"
    $Config.BaseRdsRoleGroupName      = "Base_Role_RDSServer"
    $Config.ModifyGroupsGroupName     = "Base_Access_Customer_ModifyGroups"
    $Config.AdvoPlusRoleGroupName     = "Base_Role_AdvoPlusUser"
    $Config.Member2015RoleGroupName   = "Base_Role_Member2015User"
    $Config.LegalRoleGroupName        = "Base_Role_Legal2016_User"

    if($TenantID){
    $Config.TenantID365.ID            = "$TenantID"
    }
    if($TenantAdmin){
    $Config.TenantID365.Admin         = "$TenantAdmin"
    }
    if($TenantPass){
    $Config.TenantID365.Pass          = "$TenantPass"
    }

    $Config.GroupMembership           = @(New-GroupMembershipObject -Name $Config.PublicAccessGroupName     -MembersToAdd @($Config.UserRoleGroupName))
    $Config.GroupMembership          +=   New-GroupMembershipObject -Name $Config.ReadAccessGroupName       -MembersToAdd @($Config.AllRoleGroupName)
    $Config.GroupMembership          +=   New-GroupMembershipObject -Name $Config.AllRoleGroupName          -MembersToAdd @($Config.UserRoleGroupName, $Config.SvcAccRoleGroupName, $Config.StudJurRoleGroupName, $Config.MailOnlyRoleGroupName)
    $Config.GroupMembership          +=   New-GroupMembershipObject -Name $Config.BaseUserRoleGroupName     -MembersToAdd @($Config.AllRoleGroupName)
    $Config.GroupMembership          +=   New-GroupMembershipObject -Name $Config.PrivateListDirGroupName   -MembersToAdd @($Config.AllRoleGroupName)
    if($Product -eq "AdvoPlus"){
    $Config.GroupMembership          +=   New-GroupMembershipObject -Name $Config.AdvoPlusRepoLogsGroupName -MembersToAdd @($Config.AllRoleGroupName)
    }
    if($Product -eq "Legal"){
    $Config.GroupMembership          +=   New-GroupMembershipObject -Name $Config.LegalRepoLogsGroupName -MembersToAdd @($Config.AllRoleGroupName)
    }

    $Config.FileServer.Name     = $FileServer.ToUpper()
    $Config.FileServer.Fqdn     = "$($Config.FileServer.Name).$($Config.DomainFQDN)"
    $Config.FileServer.DataPath = "$($FileServerDriveLetter):\Data"

    $Config.DataFilePath              = "\\$($Config.FileServer.Fqdn)\$($FileServerDriveLetter)$\Data"
    $Config.PrivateFolderName         = 'Private'
    $Config.PublicFolderName          = 'Public'
    $Config.FoldersFolderName         = 'Folders'
    $Config.AdvoForumFolderName       = 'AdvoForum'
    $Config.AdvoForumDocFolderName    = 'Dokumenter'
    $Config.CapLegalFolderName        = 'CapLegal'
    $Config.CapLegalDocFolderName     = 'Dokumenter'
    $Config.CapLegalConfigFolderName  = 'Config'
    $Config.CapLegalVersionFolderName = 'Version'
    $Config.PrivateShareName          = "Share_$($Config.Name)_Private$"
    $Config.PublicShareName           = "Share_$($Config.Name)_Public$"
    $Config.VersionShareName          = "Share_$($Config.Name)_Version$"
    $Config.PrivateShareUncPath       = "\\$($Config.FileServer.Fqdn)\$($Config.PrivateShareName)"
    $Config.PublicShareUncPath        = "\\$($Config.FileServer.Fqdn)\$($Config.PublicShareName)"
    $Config.VersionShareUncPath       = "\\$($Config.FileServer.Fqdn)\$($Config.VersionShareName)"
    $Config.NewCustomerDataFilePath   = Join-Path $Config.DataFilePath $Config.Name
    $Config.PrivateDataFilePath       = Join-Path $Config.NewCustomerDataFilePath  $Config.PrivateFolderName
    $Config.FoldersDataFilePath       = Join-Path $Config.NewCustomerDataFilePath  $Config.FoldersFolderName
    $Config.PublicDataFilePath        = Join-Path $Config.NewCustomerDataFilePath  $Config.PublicFolderName
    $Config.VersionDataFilePath       = Join-Path $Config.NewCustomerDataFilePath  $Config.CapLegalVersionFolderName
    $Config.AdvoForumDataFilePath     = Join-Path $Config.PublicDataFilePath       $Config.AdvoForumFolderName
    $Config.AdvoForumDocDataFilePath  = Join-Path $Config.AdvoForumDataFilePath    $Config.AdvoForumDocFolderName
    $Config.CapLegalDataFilePath      = Join-Path $Config.PublicDataFilePath       $Config.CapLegalFolderName
    $Config.CapLegalDocDataFilePath   = Join-Path $Config.CapLegalDataFilePath     $Config.CapLegalDocFolderName
    $Config.CapLegalConfigFilePath    = Join-Path $Config.PublicDataFilePath       $Config.CapLegalConfigFolderName
    $Config.CapLegalConfigFileName    = "ClientUserSettings.config"
    $Config.PoliciesUncPath           = "\\$($Config.DomainFQDN)\sysvol\$($Config.DomainFQDN)\Policies"
    $Config.PrivateDfsFolderName      = "$($Config.Name.ToLower())_private"
    $Config.PublicDfsFolderName       = "$($Config.Name.ToLower())_public"
    $Config.VersionDfsFolderName      = "$($Config.Name.ToLower())_version"
    $Config.DataDfsUncPath            = "\\$($Config.DomainNetbiosName)\data"
    $Config.PrivateDfsUncPath         = Join-Path $Config.DataDfsUncPath $Config.PrivateDfsFolderName
    $Config.FoldersDfsUncPath         = Join-Path $Config.PrivateDfsUncPath $Config.FoldersFolderName
    $Config.PublicDfsUncPath          = Join-Path $Config.DataDfsUncPath $Config.PublicDfsFolderName
    $Config.VersionDfsUncPath         = Join-Path $Config.DataDfsUncPath $Config.VersionDfsFolderName
    $Config.Folders                   = @(New-FolderObject -Name $Config.Name                      -Path $Config.DataFilePath            -Permissions @(Add-AclEntry -User $Config.PrivateListDirGroupName -FileSystemRights ListDirectory  -AccessControlType Allow -InheritanceFlags None                           -PropagationFlags None -OnlyReturnAcl))
    $Config.Folders                  +=   New-FolderObject -Name $Config.PrivateFolderName         -Path $Config.NewCustomerDataFilePath -Permissions @(Add-AclEntry -User $Config.PrivateListDirGroupName -FileSystemRights ListDirectory  -AccessControlType Allow -InheritanceFlags None                           -PropagationFlags None -OnlyReturnAcl)
    $Config.Folders                  +=   New-FolderObject -Name $Config.FoldersFolderName         -Path $Config.PrivateDataFilePath     -Permissions @(Add-AclEntry -User $Config.PrivateListDirGroupName -FileSystemRights ListDirectory  -AccessControlType Allow -InheritanceFlags None                           -PropagationFlags None -OnlyReturnAcl)
    $Config.Folders                  +=   New-FolderObject -Name $Config.PublicFolderName          -Path $Config.NewCustomerDataFilePath -Permissions @(Add-AclEntry -User $Config.PublicAccessGroupName   -FileSystemRights Modify         -AccessControlType Allow -InheritanceFlags ContainerInherit,ObjectInherit -PropagationFlags None -OnlyReturnAcl)
    $Config.Folders                  +=   New-FolderObject -Name $Config.CapLegalVersionFolderName -Path $Config.NewCustomerDataFilePath -Permissions @(Add-AclEntry -User $Config.UserRoleGroupName       -FileSystemRights ReadAndExecute -AccessControlType Allow -InheritanceFlags ContainerInherit,ObjectInherit -PropagationFlags None -OnlyReturnAcl)

    if($product -eq "AdvoPlus"){
    $Config.Folders                  +=   New-FolderObject -Name $Config.AdvoForumDocFolderName -Path $Config.AdvoForumDataFilePath
    }
    if($Product -eq "Legal"){
    $Config.Folders                  +=   New-FolderObject -Name $Config.CapLegalDocFolderName     -Path $Config.CapLegalDataFilePath
    $Config.Folders                  +=   New-FolderObject -Name $Config.CapLegalConfigFolderName  -Path $Config.PublicDataFilePath
    }
    $Config.Groups                    = @(New-GroupObject -Name $Config.PrivateListDirGroupName   -SamAccountName $Config.PrivateListDirGroupName   -GroupCategory Security -GroupScope DomainLocal -Path $Config.AccessGroupsOU)
    $Config.Groups                   +=   New-GroupObject -Name $Config.PublicAccessGroupName     -SamAccountName $Config.PublicAccessGroupName     -GroupCategory Security -GroupScope DomainLocal -Path $Config.AccessGroupsOU
    $Config.Groups                   +=   New-GroupObject -Name $Config.ReadAccessGroupName       -SamAccountName $Config.ReadAccessGroupName       -GroupCategory Security -GroupScope DomainLocal -Path $Config.AccessGroupsOU
    if($Product -eq "AdvoPlus"){
    $Config.Groups                   +=   New-GroupObject -Name $Config.AdvoPlusRepoLogsGroupName -SamAccountName $Config.AdvoPlusRepoLogsGroupName -GroupCategory Security -GroupScope DomainLocal -Path $Config.AccessGroupsOU
    }
    if($Product -eq "Legal"){
    $Config.Groups                   +=   New-GroupObject -Name $Config.LegalRepoLogsGroupName    -SamAccountName $Config.LegalRepoLogsGroupName    -GroupCategory Security -GroupScope DomainLocal -Path $Config.AccessGroupsOU
    }
    $Config.Groups                   +=   New-GroupObject -Name $Config.AllRoleGroupName          -SamAccountName $Config.AllRoleGroupName          -GroupCategory Security -GroupScope Global      -Path $Config.RolesGroupsOU
    $Config.Groups                   +=   New-GroupObject -Name $Config.UserRoleGroupName         -SamAccountName $Config.UserRoleGroupName         -GroupCategory Security -GroupScope Global      -Path $Config.RolesGroupsOU
    $Config.Groups                   +=   New-GroupObject -Name $Config.StudJurRoleGroupName      -SamAccountName $Config.StudJurRoleGroupName      -GroupCategory Security -GroupScope Global      -Path $Config.RolesGroupsOU
    $Config.Groups                   +=   New-GroupObject -Name $Config.MailOnlyRoleGroupName     -SamAccountName $Config.MailOnlyRoleGroupName     -GroupCategory Security -GroupScope Global      -Path $Config.RolesGroupsOU
    $Config.Groups                   +=   New-GroupObject -Name $Config.SvcAccRoleGroupName       -SamAccountName $Config.SvcAccRoleGroupName       -GroupCategory Security -GroupScope Global      -Path $Config.RolesGroupsOU
    $Config.Groups                   +=   New-GroupObject -Name $Config.AllDistributionGroupName  -SamAccountName $Config.AllDistributionGroupName  -GroupCategory Security -GroupScope Universal   -Path $Config.DistributionGroupsOU
    $Config.OUs                       = @(New-OUObject -Name $Config.Name      -Path $Config.CustomerOU)
    $Config.OUs                      +=   New-OUObject -Name 'Users'           -Path $Config.NewCustomerOU
    $Config.OUs                      +=   New-OUObject -Name 'Groups'          -Path $Config.NewCustomerOU
    $Config.OUs                      +=   New-OUObject -Name 'ServiceAccounts' -Path $Config.NewCustomerOU
    $Config.OUs                      +=   New-OUObject -Name 'Access'          -Path $Config.GroupsOU
    $Config.OUs                      +=   New-OUObject -Name 'Distribution'    -Path $Config.GroupsOU
    $Config.OUs                      +=   New-OUObject -Name 'Roles'           -Path $Config.GroupsOU
    $Config.OUs                      +=   New-OUObject -Name 'Mailbox'         -Path $Config.GroupsOU
    $Config.Shares                    = @(New-ShareObject -Name $Config.PrivateShareName   -Path (Resolve-UncPath -Path $Config.PrivateDataFilePath))
    $Config.Shares                   +=   New-ShareObject -Name $Config.PublicShareName    -Path (Resolve-UncPath -Path $Config.PublicDataFilePath)
    $Config.Shares                   +=   New-ShareObject -Name $Config.VersionShareName   -Path (Resolve-UncPath -Path $Config.VersionDataFilePath)
    $Config.DfsFolders                = @(New-DfsFolderObject -Path $Config.PrivateDfsUncPath -TargetPath $Config.PrivateShareUncPath -Accounts @($Config.DfsAdminGroupName, $Config.PrivateListDirGroupName))
    $Config.DfsFolders               +=   New-DfsFolderObject -Path $Config.PublicDfsUncPath  -TargetPath $Config.PublicShareUncPath  -Accounts @($Config.DfsAdminGroupName, $Config.PublicAccessGroupName)
    $Config.DfsFolders               +=   New-DfsFolderObject -Path $Config.VersionDfsUncPath -TargetPath $Config.VersionShareUncPath -Accounts @($Config.DfsAdminGroupName, $Config.UserRoleGroupName)
    $Config.TemplateAdvoPlusGpoName   = 'Template_GPO_RDS_AdvoPlus_Default_V1'
    $Config.TemplateMember2015GpoName = 'Template_GPO_RDS_Member2015_Default_V1'
    $Config.TemplateLegalGpoName      = 'Template_GPO_RDS_Legal_Default_V1'
    $Config.NewCustomerGpoName        = "$($Config.Name)_GPO_RDS_Default"

    $Config.GroupPolicy.AdvoPlusNative.Name = "Base_GPO_RDS_AdvoPlusNative"
    
    $Config.ServiceAccount.Name = "$($Config.Name)_NAV_SVC"
    $Config.ServiceAccount.UserPrincipalName = "NAV_SVC@$($Config.PrimarySmtpAddress)"

    if($Product -eq "AdvoPlus"){
    $Config.RepositoryServer.Name = "CPO-REP-01"
    $Config.RepositoryServer.Fqdn = "$($Config.RepositoryServer.Name).$($Config.DomainFQDN)"
    $Config.RepositoryServer.WebServicePath = "C:\inetpub\Legal Web Services - 81"
    $Config.RepositoryServer.WebServiceLogPath    = "C:\ProgramData\Capto\Repository Service\Logs"
    }
    if($Product -eq "Legal"){
    $Config.RepositoryServer.Name = "CPO-REP-02"
    $Config.RepositoryServer.Fqdn = "$($Config.RepositoryServer.Name).$($Config.DomainFQDN)"
    $Config.RepositoryServer.WebServicePath = "C:\inetpub\Legal Web Services - 81"
    $Config.RepositoryServer.WebServiceLogPath    = "C:\ProgramData\Capto\Repository Service\Logs"
    }

    $Config.MobileServer.Name = "CPO-MOB-01"
    $Config.MobileServer.Fqdn = "$($Config.MobileServer.Name).$($Config.DomainFQDN)"

    $Config.NAVInstanceServer.Name = switch ($Product) { "AdvoPlus" {"CPO-NST-01"}; "Member2015" {"CPO-NST-04"}; "Legal" {"CPO-NST-05"};Default {Write-Error "Unknown product '$Product'"} }
    $Config.NAVInstanceServer.Fqdn = "$($Config.NAVInstanceServer.Name).$($Config.DomainFQDN)"

    if($Product -eq "AdvoPlus"){
    $Config.NAVInstanceServer.ServiceFolderPath   = "C:\Program Files (x86)\Microsoft Dynamics NAV\60\Service"
    $Config.NAVInstanceServer.ServiceUncPath      = "\\$($Config.NAVInstanceServer.Fqdn)\C$\Program Files (x86)\Microsoft Dynamics NAV\60\Service"
    $Config.NAVInstanceServer.ServiceTemplateName = "service.org"
    }
    if($Product -eq "Legal"){
    $Config.NAVInstanceServer.ServiceFolderPath   = "C:\Program Files\Microsoft Dynamics NAV\90\Service\Instances"
    $Config.NAVInstanceServer.ServiceUncPath      = "\\$($Config.NAVInstanceServer.Fqdn)\C$\Program Files\Microsoft Dynamics NAV\90\Service\Instances"
    $Config.NAVInstanceServer.ServiceTemplateName = "service.org"
    }

    $Config.DatabaseServer.Name = switch ($Product) { "AdvoPlus" {"CPO-SQL-01"}; "Member2015" {"CPO-SQL-02"}; "Legal" {"CPO-SQL-03"}; Default {Write-Error "Unknown product '$Product'"} }
    $Config.DatabaseServer.Fqdn = "$($Config.DatabaseServer.Name).$($Config.DomainFQDN)"

    $Config.NativeDatabaseServer.Name = 'CPO-NATIVEDB-01'
    $Config.NativeDatabaseServer.Fqdn = "$($Config.NativeDatabaseServer.Name).$($Config.DomainFQDN)"
    $Config.NativeDatabaseServer.Port = 5005
    $Config.NativeDatabaseServer.DatabasePath = "E:\Database\$($Config.Name).fdb"

    $Config.SupportUser.Firstname = "Capto"
    $Config.SupportUser.Lastname  = "Support"
    $Config.SupportUser.UserPrincipalName = "capto@$($Config.PrimarySmtpAddress)"

    $Config.MailMigrationUser.Firstname = "Mail"
    $Config.MailMigrationUser.Lastname  = "Import"
    $Config.MailMigrationUser.UserPrincipalName = "mailimport@$($Config.PrimarySmtpAddress)"
    $Config.MailMigrationUser.Password  = "SYSop4$($Config.Name)"
    
    $Config.NewUser.RedirectedFolders = @(
        'Contacts'
        'Desktop'
        'Documents'
        'Downloads'
        'Favorites'
        'Links'
        'Music'
        'Pictures'
        'Start Menu'
        'Videos'
    )

    $Config.AdvoPlus.GpoSet = $AdvoPlusGpoSet

    $Config.Legal.GpoSet = $LegalGpoSet

    $Config.Member.PrecreatedServiceAccountsOU = "OU=ServiceAccounts,OU=Backend,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"

    $Config.Product.Name = $Product

    $Config.Certificate.WildcardCapto365Thumbprint = '2E326EB707DF615AF10F76BB89AE56496FDC954B'

    return $Config
}