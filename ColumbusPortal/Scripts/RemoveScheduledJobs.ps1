param(
    [string[]]$ID
)

    Import-Module (Join-Path $PSScriptRoot "Functions")

    $ErrorActionPreference = 'Stop'
    Set-StrictMode -Version 2

    $connStr = "Server=sht004;Integrated Security=true;Database=SCORCH_Tasks"
    $sqlConn = New-Object System.Data.SqlClient.SqlConnection
    $sqlConn.ConnectionString = $connStr

try {

    foreach ($i in $ID) {

        $sqlConn.Open()

        $query = "update [dbo].[ScheduledJobs] set Status = 'Deleted' WHERE id = '$i'"

        $cmd = $sqlConn.CreateCommand()
        $cmd.CommandText = $query
        $result = $cmd.ExecuteReader()

        $sqlConn.Close()
    }

} 
catch {
    throw $_
}