function New-AdminUser {
    [cmdletbinding()]
    param(
        [parameter(mandatory)]
        [string]$FirstName,
        [parameter(mandatory)]
        [string]$LastName,
        [parameter(mandatory)]
        [string]$DisplayName,
        [parameter(mandatory)]
        [string]$SamAccountName,
        [parameter(mandatory)]
        [string]$Password,
        [parameter(mandatory)]
        [string]$Department
    )

    begin{
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        $AdminUsers = Get-AdminUserConfig
    }
    process{

        if ($AdminUsers.SamAccountName -contains $SamAccountName) {
            throw "Admin user $SamAccountName already exist.."

        }
        else {

            $NewUser = @()
            $NewUser += [pscustomobject]@{
                FirstName      = $FirstName
                LastName       = $LastName
                DisplayName    = $DisplayName
                SamAccountName = $SamAccountName
                Department     = $Department

            }

            $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
            $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"
            $sqlConnection.Open()

            $Update = "INSERT INTO dbo.AdminUsers(FirstName, LastName, DisplayName, SamAccountName, Department) VALUES ('$($Newuser.FirstName)', '$($Newuser.LastName)', '$($Newuser.DisplayName)', '$($Newuser.SamAccountName)', '$($NewUser.Department)')"
            $cmd = $sqlConnection.CreateCommand()
            $cmd.CommandText = $update
            $result = $cmd.ExecuteReader()
            $sqlConnection.Close()

            $Organizations = Get-Organizations

            foreach ($org in $Organizations) {
                Write-Verbose "updating $org"
                $Config = Get-SQLEntConfig -Organization $org
                $Cred = Get-RemoteCredentials -Organization $org

                try {
                $userexist = Get-ADUser -Server $Config.DomainDC -SearchBase $Config.AdminUserOUDN -Credential $Cred -Filter "sAMAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue
                    if ($userexist) {
                        Write-Output "$SamAccountName already exist at $org"
                    }
                    else {
                        $ADUser = New-ADUser -GivenName $FirstName `
                                            -Surname $LastName `
                                            -SamAccountName $SamAccountName `
                                            -Name $DisplayName `
                                            -Server $Config.DomainDC `
                                            -Credential $Cred `
                                            -Path $Config.AdminUserOUDN `
                                            -Enabled $true `
                                            -UserPrincipalName "$($SamAccountName)@$($Config.DomainFQDN)" `
                                            -AccountPassword (ConvertTo-SecureString -String $Password -AsPlainText -Force) `
                                            -PasswordNeverExpires $true
                        Add-ADGroupMember -Identity "Domain Admins" -Members $SamAccountName -Server $Config.DomainDC -Credential $Cred
                        Write-Output "Created Admin at $Org"
                    }
                }
                catch {
                    throw $_
                }
            }
        }
    }
}