function Remove-EXTAdminUser {
    [cmdletbinding()]
    param(
        [parameter(mandatory)]
        [string]$Organization,
        [parameter(mandatory)]
        [string]$ID
    )

    begin{
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

    }
    process{
        ## Get admin user
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConnection.Open()

        # command - text
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = "select * from (select * from [dbo].[EXTAdminUsers_Done] WHERE ID = '$($ID)') t1 UNION select * from (select * from [dbo].[EXTAdminUsers_Scheduled] WHERE ID = '$($ID)') t2"

        $tables = @()

        # execute - data reader
        $reader = $sqlCmd.ExecuteReader()

        while ($reader.Read()) {

            $object = [pscustomobject] @{
                ID = $reader["ID"]
                SamAccountName = $reader["SamAccountName"]
            }
            $tables += $object
        }
        $reader.Close()

        Write-Verbose "updating $Organization"
        $Config = Get-SQLEntConfig -Organization $Organization
        $Cred = Get-RemoteCredentials -Organization $Organization

        if ($tables.SamAccountName -notlike "External") {
            try {
            $userexist = Get-ADUser -Server $Config.DomainDC -Credential $Cred -Filter "sAMAccountName -eq '$($tables.SamAccountName)'" -ErrorAction SilentlyContinue
                if (-not $userexist) {
                    throw "$($tables.SamAccountName) doesn't exist at $Organization"
                }
                else {
                    try {
                        Remove-ADUser -Identity $($tables.SamAccountName) -Confirm:$false -Server $Config.DomainDC -Credential $Cred
                        Write-Output "Removed EXT Admin at $Organization"
                    }
                    catch {
                        throw "Error from AD: $_"
                    }
                
                }
            }
            catch {
                throw $_
            }
        }

        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"

        if ($tables.SamAccountName -notlike "External") {
            $remove = "UPDATE [dbo].[EXTAdminUsers_Done] SET Status = 'Removed' WHERE [dbo].[EXTAdminUsers_Done].[ID] = '$ID'"
        }
        else {
            $remove = "UPDATE [dbo].[EXTAdminUsers_Scheduled] SET Status = 'Removed' WHERE [dbo].[EXTAdminUsers_Scheduled].[ID] = '$ID'"
        }

        $sqlConnection.Open()
        $cmd = $sqlConnection.CreateCommand()
        $cmd.CommandText = $remove
        $result = $cmd.ExecuteReader()
        $sqlConnection.Close()

        Write-Output "Database updated.."
    }
}