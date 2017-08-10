function Get-SQLSharedCustomerConfig {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

    }
    Process {
        # connection
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConnection.Open()

        # command - text
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = "select * FROM [dbo].[CASOrganizations] WHERE Organization = '{0}'" -f $Organization

        $tables = @()
        $object = @()

        # execute - data reader
        $reader = $sqlCmd.ExecuteReader()

        while ($reader.Read()) {

            $object = [pscustomobject] @{
                Organization = $reader["Organization"]
                Name = $reader["Name"]
                NavMiddleTier = $reader["NavMiddleTier"]
                SQLServer = $reader["SQLServer"]
            }
            $tables += $object
        }
        $reader.Close()


        $Config = @()
        $Config += [pscustomobject]@{
                Organization     = $tables.Organization
                Name             = $tables.Name
                NavMiddleTier    = $tables.NavMiddleTier
                SQLServer        = $tables.SQLServer
        }

        return $Config

    }
}