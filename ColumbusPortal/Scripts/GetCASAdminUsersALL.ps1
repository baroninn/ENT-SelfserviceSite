[Cmdletbinding()]
param (
    [string]$SamAccountName
)


$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
$sqlConnection.Open()

# command - text
$sqlCmd = New-Object System.Data.SqlClient.SqlCommand
$sqlCmd.Connection = $sqlConnection
$sqlCmd.CommandText =  "SELECT *
                        FROM
                        (SELECT CASAdminUsers_Done.*,
                        ROW_NUMBER() OVER (PARTITION BY UserName ORDER BY [Status] DESC) AS RN
                        FROM CASAdminUsers_Done) AS t
                        WHERE RN = 1 AND [Status] = 'Done'
                        ORDER BY UserName"

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

if ($tables -ne $null) {
    $objects = 
    foreach ($i in $tables) {
            [pscustomobject] @{
                ID = $i.ID
                Organization = $i.Organization
                Status = $i.Status
                FirstName = $i.FirstName
                LastName = $i.LastName
                UserName = $i.UserName
                Email = $i.Email
                Description = $i.Description
                Department = $i.Department
                ExpireDate = ($i.ExpireDate).ToString("dd-MM-yyyy")
                DateTime = ($i.DateTime).ToString("dd-MM-yyyy")
            }
    }
    return $objects
}