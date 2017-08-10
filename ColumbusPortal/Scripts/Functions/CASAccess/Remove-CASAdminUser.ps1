function Remove-CASAdminUser {
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
        $CASPlatform = Get-CASOrganizations -Organization $Organization

    }
    process{
        ## Get admin user
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
        $sqlConnection.Open()

        # command - text
        $sqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $sqlCmd.Connection = $sqlConnection
        $sqlCmd.CommandText = "select * from [dbo].[CASAdminUsers_Done] WHERE ID = '$($ID)'"

        $tables = @()

        # execute - data reader
        $reader = $sqlCmd.ExecuteReader()

        while ($reader.Read()) {

            $object = [pscustomobject] @{
                ID = $reader["ID"]
                UserName = $reader["UserName"]
            }
            $tables += $object
        }
        $reader.Close()

        Write-Verbose "updating $Organization"

        $SamAccountName = "CAS$($Organization)$($tables.UserName)"

        if ($CASPlatform.Platform -eq "ENT") {

            $Config = Get-SQLEntConfig -Organization $Organization
            $Cred = Get-RemoteCredentials -Organization $Organization

            try {
            $userexist = Get-ADUser -Server $Config.DomainDC -Credential $Cred -Filter "sAMAccountName -eq '$($SamAccountName)'" -ErrorAction SilentlyContinue
                if (-not $userexist) {
                    throw "$SamAccountName doesn't exist at $Organization"
                }
                else {
                    try {
                        Remove-ADUser -Identity $($SamAccountName) -Confirm:$false -Server $Config.DomainDC -Credential $Cred
                        Write-Output "Removed $($SamAccountName) at $Organization"
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

        if ($CASPlatform.Platform -eq "Shared") {

            $Cred = Get-RemoteCredentials -Shared

            try {
                
                $CustomerDC = 'AD021C1CUSTGC.customer.systemhosting.local'
                $ExchDC = 'AD024C1EXCHGC.exchange.systemhosting.local'
                $UserOU = "OU=Accounts,OU=$($Organization),OU=Microsoft Exchange Hosted Organizations,DC=exchange,DC=systemhosting,DC=local"
                $userexist = Get-ADUser -Filter "samAccountName -eq '$($SamAccountName)'" -SearchBase $UserOU -Server $ExchDC -Credential $Cred -ErrorAction SilentlyContinue

                if ($userexist) {
                    try {
                        Remove-ADUser -Identity $userexist -Server $ExchDC -Credential $Cred -Confirm:$false
                        Write-Output "Removed $($SamAccountName) at $Organization"
                    }
                    catch {
                        throw "$_"
                    }
                }
                else {
                    Write-Output "$SamAccountName doesn't exist at $Organization"
                }

            }
            catch{
                throw "$_"
            }

        }

        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"

        $remove = "UPDATE [dbo].[CASAdminUsers_Done] SET Status = 'Deleted' WHERE [dbo].[CASAdminUsers_Done].[ID] = '$ID'"

        $sqlConnection.Open()
        $cmd = $sqlConnection.CreateCommand()
        $cmd.CommandText = $remove
        $result = $cmd.ExecuteReader()
        $sqlConnection.Close()

        Write-Output "Database updated.."
    }
}