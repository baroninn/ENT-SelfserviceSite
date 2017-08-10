function Get-SQLENTConfig {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

    }
    Process {
        # connection
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConnection.Open()

        # command - text
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = "select * FROM [dbo].[Organizations] WHERE Organization = '{0}'" -f $Organization

        $tables = @()
        $object = @()

        # execute - data reader
        $reader = $sqlCmd.ExecuteReader()

        while ($reader.Read()) {

            $object = [pscustomobject] @{
                Organization = $reader["Organization"]
                Name = $reader["Name"]
                UserContainer = $reader["UserContainer"]
                ExchangeServer = $reader["ExchangeServer"]
                DomainFQDN = $reader["DomainFQDN"]
                NETBIOS = $reader["NETBIOS"]
                CustomerOUDN = $reader["CustomerOUDN"]
                AdminUserOUDN = $reader["AdminUserOUDN"]
                ExternalUserOUDN = $reader["ExternalUserOUDN"]
                EmailDomains = $reader["EmailDomains"]
                TenantID = $reader["TenantID"]
                AdminUser = $reader["AdminUser"]
                AdminPass = $reader["AdminPass"]
                AADsynced = $reader["AADsynced"]
                ADConnectServer = $reader["ADConnectServer"]
                DomainDC = $reader["DomainDC"]
                NavMiddleTier = $reader["NavMiddleTier"]
                SQLServer = $reader["SQLServer"]
                AdminRDS = $reader["AdminRDS"]
                AdminRDSPort = $reader["AdminRDSPort"]
            }
            $tables += $object
        }
        $reader.Close()


        $Config = @()
        $Config += [pscustomobject]@{
                Organization     = $tables.Organization
                Name             = $tables.Name
                UserContainer    = $tables.UserContainer
                ExchangeServer   = $tables.ExchangeServer
                DomainFQDN       = $tables.DomainFQDN
                NETBIOS          = $tables.NETBIOS
                CustomerOUDN     = $tables.CustomerOUDN
                AdminUserOUDN    = $tables.AdminUserOUDN
                ExternalUserOUDN = $tables.ExternalUserOUDN
                EmailDomains     = $tables.EmailDomains
                TenantID         = $tables.TenantID
                AdminUser        = $tables.AdminUser
                AdminPass        = $tables.AdminPass
                AADsynced        = $tables.AADsynced
                ADConnectServer  = $tables.ADConnectServer
                DomainDC         = $tables.DomainDC
                NavMiddleTier    = $tables.NavMiddleTier
                SQLServer        = $tables.SQLServer
                AdminRDS         = $tables.AdminRDS
                AdminRDSPort     = $tables.AdminRDSPort
        }

        return $Config

    }
}