function Get-Organizations {

    Begin {

        $ErrorActionPreference = "Stop"
        Set-StrictMode -Version 2

        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConnection.Open()

    }

    Process {
        
        try {
            # command - text
            $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
            $sqlCmd.Connection = $sqlConnection
            $sqlCmd.CommandText = "select * FROM [dbo].[Organizations]"

            # execute - data reader
            $reader = $sqlCmd.ExecuteReader()
            $Organizations = @()
            while ($reader.Read()) {
                $Organizations += $reader["Organization"]
            }
            $reader.Close()
        }
        catch {
            throw "ERROR: $($_.Exception)"
        }

        return $Organizations
    }
}