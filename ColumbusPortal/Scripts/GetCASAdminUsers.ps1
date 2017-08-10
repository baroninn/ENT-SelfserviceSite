[Cmdletbinding()]
param (
    [parameter(mandatory)]
    [string]$Organization,
    [string]$Status,
    [string]$ID
)


$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

$sqlConnection = New-Object System.Data.SqlClient.SqlConnection
$sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
$sqlConnection.Open()

if ($ID) {
    # command - text
    $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $sqlCmd.Connection = $sqlConnection
    $sqlCmd.CommandText = "select * FROM [dbo].[CASAdminUsers_Done] WHERE [dbo].[CASAdminUsers_Done].[ID] = '$ID'"
}
else {
    if ($status -eq "ALL") {
        # command - text
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = "SELECT * FROM [dbo].[CASAdminUsers_Done] WHERE [dbo].[CASAdminUsers_Done].[Status] = 'Done'"
    }
    if ($status -eq "Done") {
        # command - text
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = "select * FROM [dbo].[CASAdminUsers_Done] WHERE [dbo].[CASAdminUsers_Done].[Organization] = '$($Organization)' AND [dbo].[CASAdminUsers_Done].[Status] = 'Done'"
    }
    if ($status -eq "Deleted") {
        # command - text
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = "select * FROM [dbo].[CASAdminUsers_Scheduled] WHERE [dbo].[CASAdminUsers_Done].[Status] = 'Deleted'"
    }
}

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