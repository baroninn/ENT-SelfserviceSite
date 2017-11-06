[Cmdletbinding()]
param (
    [parameter(mandatory)]
    [string]$Organization
)


$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
$sqlConnection.Open()


# command - text
$sqlCmd = New-Object System.Data.SqlClient.SqlCommand
$sqlCmd.Connection = $sqlConnection
$sqlCmd.CommandText = "select * FROM [dbo].[Organizations] WHERE Organization = '$Organization'"


$tables = @()
$object = @()

# execute - data reader
$reader = $sqlCmd.ExecuteReader()

while ($reader.Read()) {

    $object = [pscustomobject] @{
        ServiceCompute = $reader["ServiceCompute"]
    }
    $tables += $object
}
$reader.Close()

if ($tables -ne $null) {
    $objects = 
    foreach ($i in $tables) {
            [pscustomobject] @{
                ServiceCompute = $i.ServiceCompute
            }
    }
    return $objects
}