function New-EXTAdminUser {
    [cmdletbinding()]
    param(
        [parameter(mandatory)]
        [string]$Organization,
        [parameter(mandatory)]
        [string]$ID,
        [parameter(mandatory)]
        [string]$FirstName,
        [parameter(mandatory)]
        [string]$LastName,
        [parameter(mandatory)]
        [string]$SamAccountName,
        [parameter(mandatory)]
        [string]$Password,
        [parameter(mandatory)]
        [string]$Company,
        [parameter(mandatory)]
        [string]$Email,
        [parameter(mandatory)]
        [string]$Description,

        [string]$Expiredate
    )

    begin{
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }
    process{

        Write-Verbose "updating $Organization"
        $Config = Get-SQLEntConfig -Organization $Organization
        $Cred = Get-RemoteCredentials -Organization $Organization

        try {
        $userexist = Get-ADUser -Server $Config.DomainDC -Credential $Cred -Filter "sAMAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue
            if ($userexist) {
                throw "$SamAccountName already exist at $Organization"
            }
            else {
               $ADUser = New-ADUser -GivenName $FirstName `
                                    -Surname $LastName `
                                    -SamAccountName $SamAccountName `
                                    -Name "EXT - $($FirstName) $($LastName)" `
                                    -Server $Config.DomainDC `
                                    -Credential $Cred `
                                    -Path $Config.CustomerOUDN `
                                    -Enabled $true `
                                    -UserPrincipalName "$($SamAccountName)@$($Config.DomainFQDN)" `
                                    -AccountPassword (ConvertTo-SecureString -String $Password -AsPlainText -Force) `
                                    -PasswordNeverExpires $true `
                                    -AccountExpirationDate $Expiredate `
                                    -Company $Company `
                                    -EmailAddress $Email `
                                    -Description $Description
                Add-ADGroupMember -Identity "G_External_Admins" -Members $SamAccountName -Server $Config.DomainDC -Credential $Cred
                Write-Output "Created EXT Admin at $Organization"
            }
        }
        catch {
            throw $_
        }

        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"

        $UpdateSCHED = "UPDATE [dbo].[EXTAdminUsers_Scheduled]  SET Status = 'Done' WHERE [dbo].[EXTAdminUsers_Scheduled].[ID] = '$ID'"
        [DateTime]$DateTime = Get-Date -Format g
        $UpdateDone = "INSERT INTO [dbo].[EXTAdminUsers_Done](Status, Organization, FirstName, LastName, Email, SamAccountName, Company, Description, DateTime, ExpireDate, Customer) VALUES ('Done', '$Organization', '$Firstname', '$Lastname', '$email', '$SamAccountName', '$Company', '$Description', '$DateTime', '$Expiredate', '$Organization')"

        $sqlConnection.Open()
        $cmd = $sqlConnection.CreateCommand()
        $cmd.CommandText = $UpdateSCHED
        $result = $cmd.ExecuteReader()
        $sqlConnection.Close()

        $sqlConnection.Open()
        $cmd = $sqlConnection.CreateCommand()
        $cmd.CommandText = $UpdateDone
        $result = $cmd.ExecuteReader()
        $sqlConnection.Close()
        Write-Output "Database updated.."

        try{

        $text=@"
                <h2>Hello Firstname</h2>
                <p>Your account has been generated, you can log in with the following info:.</p>

                <p>Username: Username1</p>
                <p>Password: Password1</p>

                <p>The account will expire on Expiredate</p>

                <img src="http://www.mintfacilities.in/admin/uploads/clients/759015580columbus.jpg">

"@
                $text = $text -replace "Firstname", "$FirstName"
                $text = $text -replace "Username1", "$($SamAccountName)@$($Config.DomainFQDN)"
                $text = $text -replace "Password1", "$Password"
                $text = $text -replace "Expiredate", "$Expiredate"


            Send-MailMessage -From 'noreply@systemhosting.dk' `
                             -SmtpServer 'relay.systemhosting.dk' `
                             -Subject "Access request to customer" `
                             -To 'jst@columbusglobal.com' `
                             -BodyAsHtml `
                             -Body "$text"

        }
        catch {
            throw $_
        }
    }
}






