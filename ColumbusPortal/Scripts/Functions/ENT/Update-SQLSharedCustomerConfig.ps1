function Update-SQLSharedCustomerConfig {
    [cmdletbinding()]
    param(
        [parameter(mandatory)]
        [string]$Organization,
        [parameter(mandatory)]
        [string]$Name,
        [parameter(mandatory)]
        [string]$NavMiddleTier,
        [parameter(mandatory)]
        [string]$SQLServer
    )

    begin{
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }
    process{

        $connStr = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConn = New-Object System.Data.SqlClient.SqlConnection
        $sqlConn.ConnectionString = $connStr

        $Update = "UPDATE [dbo].CASOrganizations(Organization, Name, NavMiddleTier, SQLServer) VALUES ('$Organization', '$Name', '$NavMiddleTier', '$SQLServer') WHERE Organization = '$Organization'"

        $sqlConn.Open()

        $cmd = $sqlConn.CreateCommand()
        $cmd.CommandText = $update
        $result = $cmd.ExecuteReader()

        $sqlConn.Close()

    }
}