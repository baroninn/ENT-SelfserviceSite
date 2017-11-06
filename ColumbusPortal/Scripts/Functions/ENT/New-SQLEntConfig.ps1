function New-SQLEntConfig {
    [cmdletbinding()]
    param(
        [parameter(mandatory)]
        [string]$Organization,
        [parameter(mandatory)]
        [string]$Name
    )

    begin{
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }
    process{

        $connStr = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConn = New-Object System.Data.SqlClient.SqlConnection
        $sqlConn.ConnectionString = $connStr
        $Update = "INSERT INTO [dbo].[Organizations](Organization, Name) VALUES ('$Organization', '$Name')"
        $sqlConn.Open()
        $cmd = $sqlConn.CreateCommand()
        $cmd.CommandText = $update
        $result = $cmd.ExecuteReader()
        $sqlConn.Close()

        $NewConfig = @()
        $NewConfig += [pscustomobject]@{
                Organization     = $Organization
                Name             = $Name
                Platform         = $null
                UserContainer    = $null
                ExchangeServer   = $null
                DomainFQDN       = $null
                NETBIOS          = $Organization
                CustomerOUDN     = $null
                AdminUserOUDN    = $null
                ExternalUserOUDN = $null
                EmailDomains     = $null
                TenantID         = $null
                AdminUser        = $null
                AdminPass        = $null
                AADsynced        = "false"
                ADConnectServer  = $null
                DomainDC         = $null
                NavMiddleTier    = $null
                SQLServer        = $null
                AdminRDS         = $null
                AdminRDSPort     = $null
                AppID            = $null
                AppSecret        = $null
                ServiceCompute   = "false"
                Service365       = "false"
                ServiceIntune    = "false"
        }

        Upload-SQLEntConfig -Organization $Organization -Config $NewConfig


    }
}