function Get-AdminUserConfig {

    Begin {
        $ErrorActionPreference = "Stop"
        Set-StrictMode -Version 2

        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConnection.Open()

    }
    Process {

        try{
            #$delete = "DELETE FROM dbo.AdminUsers"
            #$DateTime = [Datetime]::Now
            #$Update = "INSERT INTO dbo.AdminUsers(FirstName, LastName, DisplayName, SamAccountName, Department) VALUES ('$($user.FirstName)', '$($user.LastName)', '$($user.DisplayName)', '$($user.SamAccountName)', 'Drift')"
            #$Create = "Create TABLE"

            # command - text
            $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
            $sqlCmd.Connection = $sqlConnection
            $sqlCmd.CommandText = "select * FROM [dbo].[AdminUsers]"

            $tables = @()

            # execute - data reader
            $reader = $sqlCmd.ExecuteReader()

            while ($reader.Read()) {

                foreach ($i in $reader) {

                    $object= [pscustomobject] @{
                        FirstName = $reader["FirstName"]
                        LastName = $reader["LastName"]
                        DisplayName = $reader["DisplayName"]
                        SamAccountName = $reader["SamAccountName"]
                        Department = $reader["Department"]
                    }
                    $tables += $object
                }
            }
            $reader.Close()

        }
        catch{
            throw "Unable to get admin users. Error: $_"
        }

        return $tables

    }
}