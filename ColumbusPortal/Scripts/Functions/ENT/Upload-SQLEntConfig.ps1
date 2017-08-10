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

        $delete = "DELETE FROM [dbo].[Organizations] WHERE Organization = '$Organization'"
        $DateTime = [Datetime]::Now
        $Update = "INSERT INTO dbo.Organizations(Organization, Name, UserContainer, ExchangeServer, DomainFQDN, NETBIOS, CustomerOUDN, AdminUserOUDN, ExternalUserOUDN, EmailDomains, TenantID, AdminUser, AdminPass, AADSynced, ADConnectServer, DomainDC, NavMiddleTier, SQLServer, AdminRDS, AdminRDSPort, Platform) VALUES ('$Organization', '$($Config.Name)', '$($Config.UserContainer)', '$($Config.ExchangeServer)', '$($Config.DomainFQDN)', '$($Config.NETBIOS)', '$($Config.CustomerOUDN)', '$($Config.AdminUserOUDN)', '$($Config.ExternalUserOUDN)', '$($Config.EmailDomains)', '$($Config.TenantID)', '$($Config.AdminUser)', '$($Config.AdminPass)', '$($Config.AADsynced)', '$($Config.ADConnectServer)', '$($Config.DomainDC)', '$($Config.NavMiddleTier)', '$($Config.SQLServer)', '$($Config.AdminRDS)', '$($Config.AdminRDSPort)', 'ENT')"

        $sqlConn.Open()

        $cmd = $sqlConn.CreateCommand()
        $cmd.CommandText = $delete
        $result = $cmd.ExecuteReader()

        $sqlConn.Close()

        $sqlConn.Open()

        $cmd = $sqlConn.CreateCommand()
        $cmd.CommandText = $update
        $result = $cmd.ExecuteReader()

        $sqlConn.Close()

    }
}