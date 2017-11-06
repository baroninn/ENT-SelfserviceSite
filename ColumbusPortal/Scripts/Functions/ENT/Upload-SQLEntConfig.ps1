function Upload-SQLEntConfig {
    [cmdletbinding()]
    param(
        [parameter(mandatory)]
        [string]$Organization,
        [parameter(mandatory)]
        $Config
    )

    begin{
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }
    process{

        $connStr = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConn = New-Object System.Data.SqlClient.SqlConnection
        $sqlConn.ConnectionString = $connStr

        #$delete = "DELETE FROM [dbo].[Organizations] WHERE Organization = '$Organization'"
        $DateTime = [Datetime]::Now
        #$Update = "INSERT INTO dbo.Organizations(Organization, Name, UserContainer, ExchangeServer, DomainFQDN, NETBIOS, CustomerOUDN, AdminUserOUDN, ExternalUserOUDN, EmailDomains, TenantID, AdminUser, AdminPass, AADSynced, ADConnectServer, DomainDC, NavMiddleTier, SQLServer, AdminRDS, AdminRDSPort, Platform, ServiceCompute, AppID, AppSecret, Service365, ServiceIntune) VALUES ('$Organization', '$($Config.Name)', '$($Config.UserContainer)', '$($Config.ExchangeServer)', '$($Config.DomainFQDN)', '$($Config.NETBIOS)', '$($Config.CustomerOUDN)', '$($Config.AdminUserOUDN)', '$($Config.ExternalUserOUDN)', '$($Config.EmailDomains)', '$($Config.TenantID)', '$($Config.AdminUser)', '$($Config.AdminPass)', '$($Config.AADsynced)', '$($Config.ADConnectServer)', '$($Config.DomainDC)', '$($Config.NavMiddleTier)', '$($Config.SQLServer)', '$($Config.AdminRDS)', '$($Config.AdminRDSPort)', '$($Config.Platform)', '$($Config.ServiceCompute)', '$($Config.AppID)', '$($Config.AppSecret)', '$($Config.Service365)', '$($Config.ServiceIntune)')"
        $Update = "UPDATE [dbo].Organizations SET Organization = '$($Organization)', 
                                                  Platform = '$($Config.Platform)', 
                                                  Name = '$($Config.Name)', 
                                                  UserContainer = '$($Config.UserContainer)', 
                                                  ExchangeServer = '$($Config.ExchangeServer)', 
                                                  DomainFQDN = '$($Config.DomainFQDN)', 
                                                  NETBIOS = '$($Config.NETBIOS)', 
                                                  CustomerOUDN = '$($Config.CustomerOUDN)', 
                                                  AdminUserOUDN = '$($Config.AdminUserOUDN)', 
                                                  ExternalUserOUDN = '$($Config.ExternalUserOUDN)', 
                                                  EmailDomains = '$($Config.EmailDomains)', 
                                                  TenantID = '$($Config.TenantID)', 
                                                  AdminUser = '$($Config.AdminUser)', 
                                                  AdminPass = '$($Config.AdminPass)', 
                                                  AADSynced = '$($Config.AADSynced)', 
                                                  ADConnectServer = '$($Config.ADConnectServer)', 
                                                  DomainDC = '$($Config.DomainDC)', 
                                                  NavMiddleTier = '$($Config.NavMiddleTier)', 
                                                  SQLServer = '$($Config.SQLServer)', 
                                                  AdminRDS = '$($Config.AdminRDS)', 
                                                  AdminRDSPort = '$($Config.AdminRDSPort)',
                                                  ServiceCompute = '$($Config.ServiceCompute)',
                                                  AppID = '$($Config.AppID)',
                                                  AppSecret = '$($Config.AppSecret)',
                                                  Service365 = '$($Config.Service365)',
                                                  ServiceIntune = '$($Config.ServiceIntune)'

                                                  WHERE Organization = '$($Organization)'"
        
        <#
        $sqlConn.Open()

        $cmd = $sqlConn.CreateCommand()
        $cmd.CommandText = $delete
        $result = $cmd.ExecuteReader()

        $sqlConn.Close()
        #>
        $sqlConn.Open()

        $cmd = $sqlConn.CreateCommand()
        $cmd.CommandText = $update
        $result = $cmd.ExecuteReader()

        $sqlConn.Close()

    }
}