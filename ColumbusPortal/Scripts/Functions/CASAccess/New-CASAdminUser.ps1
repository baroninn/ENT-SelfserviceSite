function New-CASAdminUser {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,
        [Parameter(Mandatory)]
        [string]$FirstName,
        [Parameter(Mandatory)]
        [string]$LastName,
        [Parameter(Mandatory)]
        [string]$Email,
        [Parameter(Mandatory)]
        [string]$Description,
        [Parameter(Mandatory)]
        [string]$Department,
        [Parameter(Mandatory)]
        [string]$UserName,
        [Parameter(Mandatory)]
        [string]$Password,
        [Parameter(Mandatory)]
        [string]$ExpireDate,
        [Parameter(Mandatory)]
        [string]$ID
    )


    Begin {

        $ErrorActionPreference = "Stop"
        Set-StrictMode -Version 2

        $SamAccountName = "CAS$($Organization)$($UserName)"

        $DBExist = Get-CASAdminUser -Organization $Organization -UserName $UserName

        $CASPlatform = Get-CASOrganizations -Organization $Organization

        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $sqlConnection.ConnectionString = "Server=sht004;Integrated Security=true;Database=SSS"

        $EmailStyle = "<style type='text/css'>body {font-family: Calibri;}</style>"

    }

    Process {
        
        ## Shared customer
        if ($CASPlatform.Platform -eq 'Shared') {

            $Cred = Get-RemoteCredentials -Shared

            try {
                
                $CustomerDC = 'AD021C1CUSTGC.customer.systemhosting.local'
                $ExchDC = 'AD024C1EXCHGC.exchange.systemhosting.local'
                $UserOU = "OU=Accounts,OU=$($Organization),OU=Microsoft Exchange Hosted Organizations,DC=exchange,DC=systemhosting,DC=local"
                $GroupOU = "CN=$($Organization)_Organization_Management,OU=Organization,OU=Groups,OU=$($Organization),OU=Customers,OU=SystemHosting,DC=customer,DC=systemhosting,DC=local"
                $userexist = Get-ADUser -Filter "samAccountName -eq '$($SamAccountName)'" -Server $ExchDC -Credential $Cred -ErrorAction SilentlyContinue

                if ($userexist) {
                    Set-ADUser $userexist -Enabled $true -Server $ExchDC -Credential $Cred -AccountExpirationDate $ExpireDate
                    Set-ADAccountPassword $userexist -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force) -Confirm:$false -Server $ExchDC -Credential $Cred
                }
                else {
                    
                    try {
                        $ADUser = New-ADUser -GivenName $FirstName `
                                            -Surname $LastName `
                                            -SamAccountName $SamAccountName `
                                            -Name "CAS - $($FirstName) $($LastName)" `
                                            -Server $ExchDC `
                                            -Credential $Cred `
                                            -Path $UserOU `
                                            -Enabled $true `
                                            -UserPrincipalName "$($SamAccountName)@exchange.systemhosting.local" `
                                            -AccountPassword (ConvertTo-SecureString -AsPlainText $Password -Force) `
                                            -PasswordNeverExpires $true `
                                            -AccountExpirationDate $Expiredate `
                                            -Department $Department `
                                            -EmailAddress $Email `
                                            -Description $Description

                        $User = Get-ADUser -Filter "samAccountName -eq '$($SamAccountName)'" -Server $ExchDC -Credential $Cred -ErrorAction SilentlyContinue

                        Add-ADGroupMember -Identity "$($Organization)_Organization_Management" -Members $user -Server $CustomerDC -Credential $Cred
                        Add-ADGroupMember -Identity "Access_Level_10" -Members $user -Server $CustomerDC -Credential $Cred
                        Write-Verbose "Created CAS Admin at $Organization"
                    }
                    catch {
                        "ERROR: $_"
                    }
                }

            }
            catch{
                throw "$_"
            }

            $text = Get-Content C:\ENTScriptsTest\SharedCASEmail.txt -Encoding UTF8
            $text = $text -replace "FullName", "$FirstName $LastName"
            $text = $text -replace "Username1", "EXCHANGE\$($SamAccountName)"
            $text = $text -replace "Password1", "$Password"
            $text = $text -replace "Expiredate", "$Expiredate"
            $text = $text -replace "SQLServer", "$($CASPlatform.SQLServer)"
            $text = $text -replace "NavMiddleTier", "$($CASPlatform.NavMiddleTier)"

            $RDPShared = Get-Content C:\ENTScriptsTest\Shared.rdp -Encoding UTF8
                $RDPShared = $RDPShared -replace "Organization", "$Organization"
                $RDPShared = $RDPShared -replace "SamAccountName", "EXCHANGE\$($SamAccountName)"
            $RDPShared | Out-File "C:\ENTScriptstest\RDPTemp\$($SamAccountName).rdp"
            $Attachements = @()
            $Attachements += "C:\ENTScriptstest\RDPTemp\$($SamAccountName).rdp"


            Send-MailMessage -From 'noreply@systemhosting.dk' `
                                -SmtpServer 'relay.systemhosting.dk' `
                                -Subject "Access request to $($CASPlatform.Name)" `
                                -To "$Email" `
                                -BodyAsHtml `
                                -Body "$text" `
                                -Attachments $Attachements `
                                -Encoding ([System.Text.Encoding]::UTF8)

            Remove-Item "C:\ENTScriptstest\RDPTemp\$($SamAccountName).rdp" -Force

        }
        ## Enterprise customer #########################################
        else {
            $Cred = Get-RemoteCredentials -Organization $Organization
            $Config = Get-SQLENTConfig -Organization $Organization

            try {
                $userexist = Get-ADUser -Filter "samAccountName -eq '$($SamAccountName)'" -Server $Config.DomainDC -Credential $Cred -ErrorAction SilentlyContinue

                if ($userexist) {
                    Set-ADUser $userexist -Enabled $true -Server $Config.DomainDC -Credential $Cred -AccountExpirationDate $ExpireDate
                    Set-ADAccountPassword $userexist -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force) -Confirm:$false -Server $Config.DomainDC -Credential $Cred
                }
                else {
                    
                    try {
                        $ADUser = New-ADUser -GivenName $FirstName `
                                            -Surname $LastName `
                                            -SamAccountName $SamAccountName `
                                            -Name "CAS - $($FirstName) $($LastName)" `
                                            -Server $Config.DomainDC `
                                            -Credential $Cred `
                                            -Path $Config.ExternalUserOUDN `
                                            -Enabled $true `
                                            -UserPrincipalName "$($SamAccountName)@$($Config.DomainFQDN)" `
                                            -AccountPassword (ConvertTo-SecureString -AsPlainText $Password -Force) `
                                            -PasswordNeverExpires $true `
                                            -AccountExpirationDate $Expiredate `
                                            -Department $Department `
                                            -EmailAddress $Email `
                                            -Description $Description

                        $User = Get-ADUser -Filter "samAccountName -eq '$($SamAccountName)'" -Server $Config.DomainDC -Credential $Cred -ErrorAction SilentlyContinue

                        Add-ADGroupMember -Identity "G_External_Admins" -Members $user -Server $Config.DomainDC -Credential $Cred
                        Write-Verbose "Created CAS Admin at $Organization"
                    }
                    catch {
                        "ERROR: $_"
                    }
                }

            }
            catch{
                throw "$_"
            }

            $text = Get-Content C:\ENTScriptsTest\ENTCASEmail.txt -Encoding UTF8
            $text = $text -replace "FullName", "$FirstName $LastName"
            $text = $text -replace "Username1", "$($SamAccountName)@$($Config.DomainFQDN)"
            $text = $text -replace "Password1", "$Password"
            $text = $text -replace "Expiredate", "$Expiredate"
            $text = $text -replace "SQLServer", "$($CASPlatform.SQLServer)"
            $text = $text -replace "NavMiddleTier", "$($CASPlatform.NavMiddleTier)"

            $RDPShared = Get-Content C:\ENTScriptsTest\ENT.rdp -Encoding UTF8
                $RDPShared = $RDPShared -replace "Organization", "$($Config.AdminRDS)"
                $RDPShared = $RDPShared -replace "SamAccountName", "$($SamAccountName)@$($Config.DomainFQDN)"
                $RDPShared = $RDPShared -replace "Port", "$($Config.AdminRDSPort)"
            $RDPShared | Out-File "C:\ENTScriptstest\RDPTemp\$($SamAccountName).rdp"
            $Attachements = @()
            $Attachements += "C:\ENTScriptstest\RDPTemp\$($SamAccountName).rdp"


            Send-MailMessage -From 'noreply@systemhosting.dk' `
                                -SmtpServer 'relay.systemhosting.dk' `
                                -Subject "Access request to $($CASPlatform.Name)" `
                                -To "$Email" `
                                -BodyAsHtml `
                                -Body "$text" `
                                -Attachments $Attachements `
                                -Encoding ([System.Text.Encoding]::UTF8)

            Remove-Item "C:\ENTScriptstest\RDPTemp\$($SamAccountName).rdp" -Force

        }

        ## Update DB
        $UpdateSCHED = "UPDATE [dbo].[CASAdminUsers_Scheduled]  SET Status = 'Done' WHERE [dbo].[CASAdminUsers_Scheduled].[ID] = '$ID'"
        [DateTime]$DateTime = Get-Date -Format g
        if ($DBExist) {
            $UpdateDone = "UPDATE [dbo].[CASAdminUsers_Done]  SET ExpireDate = '$ExpireDate' WHERE [dbo].[CASAdminUsers_Done].[ID] = '$($DBExist.ID)'"
        }
        else {
            $UpdateDone = "INSERT INTO [dbo].[CASAdminUsers_Done](Status, Organization, FirstName, LastName, Email, UserName, Department, Description, DateTime, ExpireDate) VALUES ('Done', '$Organization', '$Firstname', '$Lastname', '$email', '$UserName', '$Department', '$Description', '$DateTime', '$Expiredate')"
        }
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
        Write-Verbose "Database updated.."

    }
    End {
    }
}