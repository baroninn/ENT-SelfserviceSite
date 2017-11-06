function Update-SQLNAVCustomerConfig {
    [cmdletbinding()]
    param(
        [parameter(mandatory)]
        [string]$Organization,
        [parameter(mandatory)]
        [string]$Platform,
        [parameter(mandatory)]
        [string]$Name,

        [string]$NavMiddleTier,
        [string]$SQLServer,
        [string]$LoginInfo,
        [string]$RDSServer
    )

    begin{
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }
    process{

        $connStr = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConn = New-Object System.Data.SqlClient.SqlConnection
        $sqlConn.ConnectionString = $connStr

        $Update = "UPDATE [dbo].CASOrganizations SET Organization = '$($Organization)', Platform = '$($Platform)', Name = '$($Name)', NavMiddleTier = '$($NavMiddleTier)', SQLServer = '$($SQLServer)', LoginInfo = '$($LoginInfo)', RDSServer = '$($RDSServer)' WHERE Organization = '$($Organization)'"

        $sqlConn.Open()

        $cmd = $sqlConn.CreateCommand()
        $cmd.CommandText = $update
        $result = $cmd.ExecuteReader()

        $sqlConn.Close()

    }
}