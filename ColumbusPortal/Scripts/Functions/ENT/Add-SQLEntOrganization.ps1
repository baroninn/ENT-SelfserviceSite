function Add-SQLEntOrganization {
    [cmdletbinding()]
    param(
        [parameter(mandatory)]
        [string]$Organization,
        [parameter(mandatory)]
        $Name
    )

    begin{
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }
    process{

        $connStr = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConn = New-Object System.Data.SqlClient.SqlConnection
        $sqlConn.ConnectionString = $connStr

        $Update = "INSERT INTO dbo.Organizations(Organization, Name) VALUES ('$Organization', '$Name')"

        $sqlConn.Open()

        $cmd = $sqlConn.CreateCommand()
        $cmd.CommandText = $update
        $result = $cmd.ExecuteReader()

        $sqlConn.Close()

    }
}