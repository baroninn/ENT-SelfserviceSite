function Get-ScheduledCASAdminUsers {

    Begin {
        $ErrorActionPreference = "Stop"
        Set-StrictMode -Version 2

        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConnection.Open()

    }
    Process {

        try{

            # command - text
            $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
            $sqlCmd.Connection = $sqlConnection
            $sqlCmd.CommandText = "select * FROM [dbo].[CASAdminUsers_Scheduled] WHERE Status = 'Scheduled'"

            $tables = @()

            # execute - data reader
            $reader = $sqlCmd.ExecuteReader()

            while ($reader.Read()) {

                $object= [pscustomobject] @{
                    ID = $reader["ID"]
                    Status = $reader["Status"]
                    FirstName = $reader["FirstName"]
                    LastName = $reader["LastName"]
                    Email = $reader["Email"]
                    Description = $reader["Description"]
                    Department = $reader["Department"]
                    Organization = $reader["Organization"]
                    UserName = $reader["UserName"]
                    DateTime = $reader["DateTime"]
                    ExpireDate = $reader["ExpireDate"]
                }

                $tables += $object
            }
            $reader.Close()

        }
        catch{
            throw "Unable to get CAS admin users. Error: $_"
        }

        return $tables

    }
}