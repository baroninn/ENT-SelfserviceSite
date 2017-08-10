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
    $sqlCmd.CommandText = "select * FROM [dbo].[EXTAdminUsers_Scheduled] WHERE [dbo].[EXTAdminUsers_Scheduled].[ID] = '$ID'"
}
else {
    if ($status -eq "ALL") {
        # command - text
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = "SELECT * FROM [dbo].[EXTAdminUsers_Done]
                               WHERE [dbo].[EXTAdminUsers_Done].[Status] = 'Done'
                               UNION
                               SELECT * FROM [dbo].[EXTAdminUsers_Scheduled] 
                               WHERE [dbo].[EXTAdminUsers_Scheduled].[Status] = 'Scheduled'"
    }
    if ($status -eq "Done") {
        # command - text
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = "select * FROM [dbo].[EXTAdminUsers_Done] WHERE [dbo].[EXTAdminUsers_Done].[Organization] = '$($Organization)' AND [dbo].[EXTAdminUsers_Done].[Status] = 'Done'"
    }
    if ($status -eq "Scheduled") {
        # command - text
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = "select * FROM [dbo].[EXTAdminUsers_Scheduled] WHERE [dbo].[EXTAdminUsers_Scheduled].[Status] = 'Scheduled'"
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
        SamAccountName = $reader["SamAccountName"]
        Email = $reader["Email"]
        Description = $reader["Description"]
        Company = $reader["Company"]
        Customer = $reader["Customer"]
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
                SamAccountName = $i.SamAccountName
                Email = $i.Email
                Description = $i.Description
                Company = $i.Company
                Customer = $i.Customer
                ExpireDate = ($i.ExpireDate).ToString("dd-MM-yyyy")
                DateTime = ($i.DateTime).ToString("dd-MM-yyyy")
            }
    }
    return $objects
}