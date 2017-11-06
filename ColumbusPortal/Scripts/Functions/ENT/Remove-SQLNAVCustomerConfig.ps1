function Remove-SQLNAVCustomerConfig {
    [cmdletbinding()]
    param(
        [parameter(mandatory)]
        [string]$Organization
    )

    begin{
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }
    process{

        $connStr = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConn = New-Object System.Data.SqlClient.SqlConnection
        $sqlConn.ConnectionString = $connStr

        $Delete = "DELETE FROM [dbo].[CASOrganizations] WHERE Organization = '$Organization'"

        $sqlConn.Open()

        $cmd = $sqlConn.CreateCommand()
        $cmd.CommandText = $Delete
        $result = $cmd.ExecuteReader()

        $sqlConn.Close()

    }
}