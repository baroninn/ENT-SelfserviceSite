<#
    .DESCRIPTION
    Function for creating the Legal (Nav2016) instance and settings

    .NOTES
        AUTHOR: Jakob Strøm
        LASTEDIT: November 07, 2016


#>

function New-LegalService2016 {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Path,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$DatabaseServer,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$DatabaseName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ServerInstance,
        
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$RepositoryServer,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Domain = $env:USERDNSDOMAIN,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [pscredential]$ServiceAccount,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ComputerName

    )

## - Create scriptblock for invoke, and remember positional params..

$scriptblock = {
    param (
            [string]$TenantName,
            [string]$DatabaseServer,
            [string]$DatabaseName,
            [pscredential]$ServiceAccount
        )

        Import-Module "C:\Program Files\Microsoft Dynamics NAV\90\Service\NavAdminToolCapto.ps1" | Out-Null

        New-NAVServerInstance -DatabaseServer $DatabaseServer `
                              -DatabaseName $DatabaseName `
                              -ManagementServicesPort "7045" `
                              -ClientServicesPort "7046" `
                              -SOAPServicesPort "7047" `
                              -ODataServicesPort "7048" `
                              -ServerInstance $TenantName `
                              -ServiceAccount user `
                              -DatabaseInstance '' `
                              -ServiceAccountCredential $ServiceAccount
    }

    Write-Verbose "Setting up Nav 2016 instance on $ComputerName"
    Invoke-Command -ComputerName $ComputerName -ScriptBlock $scriptblock -ArgumentList $TenantName,
                                                                                       $DatabaseServer,
                                                                                       $DatabaseName,
                                                                                       $ServiceAccount



    $exeName     = 'Microsoft.Dynamics.Nav.Server.exe'
    $configName  = 'CustomSettings.config'
    $serviceUser = Get-ADUser -Identity $ServiceAccount.GetNetworkCredential().UserName -Server $Domain
    $serviceName = 'MicrosoftDynamicsNavServer$' + $TenantName

    if ($Path -like "\\*") {
        Write-Error "Path must not be an UNC"
    }

    if ($ComputerName) {
        $testPath = "\\$ComputerName\$Path".Replace(':', '$')
    }
    else {
        $testPath = $Path
    }

    $testConfigPath = Join-Path $testPath $configName

    if (-not (Test-Path $testPath)) {
        Write-Error "Path '$testPath' was not found"
    }
    elseif (-not (Test-Path $testConfigPath)) {
        Write-Error "Config file '$testConfigPath' was not found"
    }

    Write-Verbose "Loading config file '$testConfigPath'..."
    [xml]$xmlConfig = Get-Content -Path $testConfigPath

    $xmlConfig.appSettings.add.Where{$_.key -eq 'DatabaseServer'}[0].value = $DatabaseServer
    $xmlConfig.appSettings.add.Where{$_.key -eq 'DatabaseName'}[0].value = $DatabaseName
    $xmlConfig.appSettings.add.Where{$_.key -eq 'ServerInstance'}[0].value = $ServerInstance
    $xmlConfig.appSettings.add.Where{$_.key -eq 'ServicesLanguage'}[0].value = 'da-DK'
    $xmlConfig.appSettings.add.Where{$_.key -eq 'ServicesDefaultTimeZone'}[0].value = 'Server Time Zone'

    Write-Verbose "Saving config file '$testConfigPath'..."
    $xmlConfig.Save($testConfigPath)

    Write-Verbose "Setting 'SeServiceLogonRight' for $($ServiceAccount.UserName)..."
        if ($ComputerName) {
            Grant-UserRight -Account $serviceUser.SID.Value -Right SeServiceLogonRight -Computer $ComputerName
        }
        else {
            Grant-UserRight -Account $serviceUser.SID.Value -Right SeServiceLogonRight
        }

        ## Create DB from template file..
    $DBQuery = @(
        "RESTORE DATABASE $($TenantName) FROM DISK='C:\temp\Template_Dummy_UsedForCustCreation.bak' WITH REPLACE, RECOVERY, 

        MOVE 'Demo Database NAV (7-0)_data' TO 'F:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$($TenantName)_Data.mdf', 
        MOVE 'Demo Database NAV (7-0)_log' TO 'L:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Data\$($TenantName)_Log.ldf'"
    )

    $script = {
        [Cmdletbinding()]
        param (
        [Parameter(Mandatory)]
        [string]$DBQuery
        )
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Invoke-SqlCmd -Query $DBQuery
    }

    Invoke-Command -ComputerName $Config.DatabaseServer.Fqdn -ScriptBlock $script -ArgumentList $DBQuery

    ## Set DB owner for SVC user

    $query = @"
USE [{0}]
GO

EXEC sp_grantlogin N'CAPTO\{0}_NAV_SVC'
CREATE USER "CAPTO\{0}_NAV_SVC" FOR LOGIN "CAPTO\{0}_NAV_SVC"
EXEC sp_addrolemember N'db_owner', N'CAPTO\{0}_NAV_SVC'

EXEC sp_grantlogin N'CAPTO\{0}_capto'
CREATE USER "CAPTO\{0}_capto" FOR LOGIN "CAPTO\{0}_capto"
EXEC sp_addrolemember N'db_owner', N'CAPTO\{0}_capto'

"@

    $query = $query -f $TenantName.ToUpper()

    $script = {
        [Cmdletbinding()]
        param (
        [Parameter(Mandatory)]
        [string]$query
        )
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Invoke-SqlCmd -Query $query
    }

    Invoke-Command -ComputerName $Config.DatabaseServer.Fqdn -ScriptBlock $script -ArgumentList $query

    ## Give serviceaccount/capto access to NAV DB

    $Capto = Get-ADUser -Identity "$($TenantName)_capto" -Server $Domain

    $SQLQuery = @(
        "USE $($TenantName);
        DECLARE @USERSID uniqueidentifier, @WINDOWSSID nvarchar(119), @USERNAME     nvarchar(50), @USERSIDTXT varchar(50)

        SELECT NEWID()
        SET @USERNAME   = 'CAPTO\$($serviceUser.Name)'
        SET @USERSID    = NEWID()
        SET @USERSIDTXT = CONVERT(VARCHAR(50), @USERSID)
        SET @WINDOWSSID = '$($ServiceUser.SID)'

        INSERT INTO [dbo].[User]
        ([User Security ID],[User Name],[Contact Email],[Full Name],[State],[Expiry Date], [Windows Security ID],[Change Password],[License Type],[Authentication Email])
        VALUES
        (@USERSID,@USERNAME,'support@systemhosting.dk','',0,'1753-01-01 00:00:00.000',@WINDOWSSID,0,0,'')

        INSERT INTO [dbo].[User Property]
        ([User Security ID],[Password],[Name Identifier],[Authentication Key],    [WebServices Key],[WebServices Key Expiry Date],[Authentication Object ID])
        VALUES
        (@USERSID,'','','','','1753-01-01 00:00:00.000','')

        INSERT INTO [dbo].[Access Control]([User Security ID],[Role ID],[Company Name],[App ID],[Scope])
        VALUES
        (@USERSID,'SUPER','','00000000-0000-0000-0000-000000000000',0)
        GO
        
        USE $($TenantName);
        DECLARE @USERSID uniqueidentifier, @WINDOWSSID nvarchar(119), @USERNAME     nvarchar(50), @USERSIDTXT varchar(50)

        SELECT NEWID()
        SET @USERNAME   = 'CAPTO\$($Capto.SamAccountName)'
        SET @USERSID    = NEWID()
        SET @USERSIDTXT = CONVERT(VARCHAR(50), @USERSID)
        SET @WINDOWSSID = '$($capto.SID)'

        INSERT INTO [dbo].[User]
        ([User Security ID],[User Name],[Contact Email],[Full Name],[State],[Expiry Date], [Windows Security ID],[Change Password],[License Type],[Authentication Email])
        VALUES
        (@USERSID,@USERNAME,'support@systemhosting.dk','',0,'1753-01-01 00:00:00.000',@WINDOWSSID,0,0,'')

        INSERT INTO [dbo].[User Property]
        ([User Security ID],[Password],[Name Identifier],[Authentication Key],    [WebServices Key],[WebServices Key Expiry Date],[Authentication Object ID])
        VALUES
        (@USERSID,'','','','','1753-01-01 00:00:00.000','')

        INSERT INTO [dbo].[Access Control]([User Security ID],[Role ID],[Company Name],[App ID],[Scope])
        VALUES
        (@USERSID,'SUPER','','00000000-0000-0000-0000-000000000000',0)
        GO"                       
    )

    $script = {
        [Cmdletbinding()]
        param (
        [Parameter(Mandatory)]
        [string]$SQLQuery
        )
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Invoke-SqlCmd -Query $SQLQuery
    }

    Invoke-Command -ComputerName $Config.DatabaseServer.Fqdn -ScriptBlock $script -ArgumentList $SQLQuery

    ## Start service so Reg hive gets created, then add reg keys..

    Write-Verbose "Starting service '$serviceName'..."
        if ($ComputerName) {
            Get-Service -Name $serviceName -ComputerName $ComputerName | Start-Service -ErrorAction SilentlyContinue
        }
        else {
            Get-Service -Name $serviceName | Start-Service
        }

        $setLegalRegistryScript = {
        param (
            $RepositoryServer,
            $TenantName,
            $ServiceAccount,
            $ServiceUser
        )

        $regPath = "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$($ServiceUser.SID)\Software\Wow6432Node\Capto\Advo\Repository"
        New-Item -Path $regPath -ItemType Key -Force | Out-Null
        Set-ItemProperty -Path $regPath -Name BaseAddress -Value "http://$($RepositoryServer):81/$TenantName"
        Set-ItemProperty -Path $regPath -Name Ntlm -Value 1
        Set-ItemProperty -Path $regPath -Name Spn  -Value "HTTP/$($RepositoryServer)"

        $accessrule = New-Object System.Security.AccessControl.RegistryAccessRule ("Authenticated Users", "ReadKey", "ObjectInherit,ContainerInherit", "None", "Allow")
        $acl = Get-Acl -Path $regPath
        $acl.AddAccessRule($accessrule)
        Set-Acl -Path $regPath -AclObject $acl
    }

    Write-Verbose "Setting registry settings for '$($ServiceAccount.UserName)'..."
    if ($ComputerName) {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock $setLegalRegistryScript -ArgumentList $RepositoryServer, $TenantName, $ServiceAccount, $serviceUser
    }
    else {
        $setLegalRegistryScript.Invoke()
    }
}