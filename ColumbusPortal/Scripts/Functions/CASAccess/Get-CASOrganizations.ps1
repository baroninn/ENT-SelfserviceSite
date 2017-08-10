function Get-CASOrganizations {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [ValidateSet("All","Shared","Enterprise")] 
        [string]$Type,
        [string]$Organization
    )


    Begin {

        $ErrorActionPreference = "Stop"
        Set-StrictMode -Version 2

        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConnection.Open()

        if ($Organization) {
            # command - text
            $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
            $sqlCmd.Connection = $sqlConnection
            $sqlCmd.CommandText = "select Organization, Name, NavMiddleTier, SQLServer, Platform FROM [dbo].[CASOrganizations] WHERE Organization = '$Organization' UNION Select Organization, Name, NavMiddleTier, SQLServer, Platform FROM [dbo].[Organizations] WHERE Organization = '$Organization'"
        }
        else {
            if ($Type -eq 'All') {
                # command - text
                $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
                $sqlCmd.Connection = $sqlConnection
                $sqlCmd.CommandText = "select Organization, Name, NavMiddleTier, SQLServer, Platform FROM [dbo].[CASOrganizations] UNION Select Organization, Name, NavMiddleTier, SQLServer, Platform FROM [dbo].[Organizations]"
            }
            if ($Type -eq 'Shared') {
                # command - text
                $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
                $sqlCmd.Connection = $sqlConnection
                $sqlCmd.CommandText = "select * FROM [dbo].[CASOrganizations]"
            }
            if ($Type -eq 'Enterprise') {
                # command - text
                $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
                $sqlCmd.Connection = $sqlConnection
                $sqlCmd.CommandText = "select * FROM [dbo].[Organizations]"
            }
        }

    }
    Process {

        try {

            # execute - data reader
            $reader = $sqlCmd.ExecuteReader()

            $Org = @()


            while ($reader.Read()) {
                $object= [pscustomobject] @{
                    Organization = $reader["Organization"]
                    Name = $reader["Name"]
                    NavMiddleTier = $reader["NavMiddleTier"]
                    SQLServer = $reader["SQLServer"]
                    Platform = $reader["Platform"]
                }
                $Org += $object
            }
            $reader.Close()

        }
        catch{
            throw "Unable to get organizations. Error: $_"
        }
        return $Org | sort Organization
    }

    END {
        $sqlConnection.Close()
    }
}