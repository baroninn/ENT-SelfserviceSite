function Remove-AdminUser {
    [cmdletbinding()]
    param(
        [parameter(mandatory)]
        [string]$SamAccountName
    )

    begin{
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        $AdminUsers = Get-AdminUserConfig
    }
    process{

        if ($AdminUsers.SamAccountName -contains $SamAccountName) {

            #$NewConfig = $AdminUsers | where{$_.SamAccountName -ne $SamAccountName}
            #$NewConfig | ConvertTo-Json | Out-File ("C:\ENTConfig\AdminUsers\AdminUsers.txt") -Force -Encoding utf8

            $Organizations = Get-Organizations

            try {
                foreach ($org in $Organizations) {
                    Write-Verbose "updating $org"
                    $Config = Get-SQLEntConfig -Organization $org
                    $Cred = Get-RemoteCredentials -Organization $org

                    try {
                    $userexist = Get-ADUser -Server $Config.DomainDC -SearchBase $Config.AdminUserOUDN -Credential $Cred -Filter "sAMAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue
                        if ($userexist) {
                        
                            Remove-ADUser -Identity $userexist -Server $Config.DomainDC -Credential $Cred -Confirm:$false | Out-Null
                            Write-Output "$SamAccountName has been deleted at $org"

                        }
                        else {
                            Write-Output "Admin not found at $Org"
                        }
                    }
                    catch {
                        throw $_
                    }
                }

                $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
                $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
                $sqlConnection.Open()

                $delete = "DELETE FROM [dbo].[AdminUsers] WHERE SamAccountName = '$SamAccountName'"
                $cmd = $sqlConnection.CreateCommand()
                $cmd.CommandText = $delete
                $result = $cmd.ExecuteReader()
                $sqlConnection.Close()
                Write-Output "$SamAccountName has been deleted from Database!"
            }
            catch{
                throw "ERROR deleting user: $_" 
            }
                

        }
        else {
            throw "Admin user $SamAccountName doesnt exist.."

            
        }
    }
}