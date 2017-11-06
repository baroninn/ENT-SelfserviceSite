[cmdletbinding()]
param(
    [parameter(mandatory)]
    [string]$UserName
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Functions")

$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
$sqlConnection.Open()

# command - text
$sqlCmd = New-Object System.Data.SqlClient.SqlCommand
$sqlCmd.Connection = $sqlConnection
$sqlCmd.CommandText = "select * FROM [dbo].[CASAdminUsers_Done] WHERE [dbo].[CASAdminUsers_Done].[UserName] = '$UserName' AND Status = 'Done'"

$tables = @()
$object = @()

# execute - data reader
$reader = $sqlCmd.ExecuteReader()

while ($reader.Read()) {

    $object = [pscustomobject] @{
        ID = $reader["ID"]
        Organization = $reader["Organization"]
        Status = $reader["Status"]
        FirstName = $reader["Firstname"]
        LastName = $reader["Lastname"]
        UserName = $reader["UserName"]
        Email = $reader["Email"]
        Description = $reader["Description"]
        Department = $reader["Department"]
        ExpireDate = $reader["ExpireDate"]
        DateTime = $reader["DateTime"]
    }
    $tables += $object
}
$reader.Close()

foreach ($i in $tables) {
    Remove-CASAdminUser -Organization $i.Organization -ID $i.ID
}