function Get-ScomAlerts {
    [Cmdletbinding()]
    param (
        [switch]$Freespace,

        [switch]$LatestAlerts,

        [switch]$PendingReboot,

        [switch]$Live
    )

    Begin {

        $ErrorActionPreference = "Stop"
        Set-StrictMode -Version 2

        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConnection.Open()

    }

    Process {

        if ($LatestAlerts) {

            # command - text
            $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
            $sqlCmd.Connection = $sqlConnection
            $sqlCmd.CommandText = "select Alerts FROM [dbo].[LatestAlerts]"

            # execute - data reader
            $reader = $sqlCmd.ExecuteReader()
            $tables = @()
            while ($reader.Read()) {
                $tables += $reader["Alerts"]
            }
            $reader.Close()

            $LatestAlertsdb = $tables | ConvertFrom-Json

            if ($LatestAlertsdb -ne $null) {
                $objects = 
                foreach ($i in $LatestAlertsdb) {
        
                    if($i.PrincipalName -ne $null){
                        [pscustomobject] @{
                            Name = $i.Name
                            PrincipalName = $i.PrincipalName
                            TimeRaised = $i.TimeRaised
                            Severity = $i.Severity
                            Description = $i.Description
                        }
                    }
                    else {
                        [pscustomobject] @{
                            Name = $i.Name
                            PrincipalName = "None"
                            TimeRaised = $i.TimeRaised
                            Severity = $i.Severity
                            Description = $i.Description
                        }
                    }
                }
                return $objects
            }
        }

        if ($Freespace) {

            # command - text
            $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
            $sqlCmd.Connection = $sqlConnection
            $sqlCmd.CommandText = "select Alerts FROM [dbo].[FreeSpaceAlerts]"

            # execute - data reader
            $reader = $sqlCmd.ExecuteReader()
            $tables = @()
            while ($reader.Read()) {
                $tables += $reader["Alerts"]
            }
            $reader.Close()

            $FreeSpaceAlerts = $tables | ConvertFrom-Json

            if ($FreeSpaceAlerts -ne $null) {
                $objects = 
                foreach ($i in $FreeSpaceAlerts) {
        
                    if($i.PrincipalName -ne $null){
                        [pscustomobject] @{
                            Name = $i.Name
                            PrincipalName = $i.PrincipalName
                            TimeRaised = $i.TimeRaised
                            Severity = $i.Severity
                            Description = $i.Description
                        }
                    }
                    else {
                        [pscustomobject] @{
                            Name = $i.Name
                            PrincipalName = "None"
                            TimeRaised = $i.TimeRaised
                            Severity = $i.Severity
                            Description = $i.Description
                        }
                    }
                }
                return $objects
            }
        }

        if ($PendingReboot) {

            # command - text
            $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
            $sqlCmd.Connection = $sqlConnection
            $sqlCmd.CommandText = "select Alerts FROM [dbo].[PendingReboots]"

            # execute - data reader
            $reader = $sqlCmd.ExecuteReader()
            $tables = @()
            while ($reader.Read()) {
                $tables += $reader["Alerts"]
            }
            $reader.Close()

            $PendingReboots = $tables | ConvertFrom-Json

            if ($PendingReboots -ne $null) {
                $objects = 
                foreach ($i in $PendingReboots) {
        
                    if($i.PrincipalName -ne $null){
                        [pscustomobject] @{
                            Name = $i.Name
                            PrincipalName = $i.PrincipalName
                            TimeRaised = $i.TimeRaised
                            Severity = $i.Severity
                            Description = $i.Description
                        }
                    }
                    else {
                        [pscustomobject] @{
                            Name = $i.Name
                            PrincipalName = "None"
                            TimeRaised = $i.TimeRaised
                            Severity = $i.Severity
                            Description = $i.Description
                        }
                    }
                }
                return $objects | sort PrincipalName
            }
        }

    }
}