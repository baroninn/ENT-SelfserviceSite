function Create-PSAppRegistration {
    [Cmdletbinding()]
    param(
    [Parameter(Mandatory = $true)]
    [string]$Organization
    )
    
    Begin {

        Import-Module AzureAD > $null

        $Config = Get-SQLEntConfig -Organization $Organization
        
    }
    Process {

        if (!($Config.AdminUser -or $Config.AdminPass)) {
            throw "Either Tenant Admin User og Pass is missing from conf. Please update the customer configuration with this before continuing.."
        }

        $User             = "$($Config.AdminUser)"
        $Pass             = "$($Config.AdminPass)"
        $Credential       = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, ($Pass | ConvertTo-SecureString -AsPlainText -Force)

        Connect-AzureAD -Credential $Credential > $null

        $application = Get-Content C:\AzureAPPPermissions.txt | ConvertFrom-Json

        if(!($myApp = Get-AzureADApplication -Filter "DisplayName eq '$($application.DisplayName)'"  -ErrorAction SilentlyContinue))
        {

            $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
            $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
            $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
            $aesManaged.BlockSize = 128
            $aesManaged.KeySize = 256
            $aesManaged.GenerateKey()
            $key = [System.Convert]::ToBase64String($aesManaged.Key)

            $credobject = New-Object Microsoft.Open.AzureAD.Model.PasswordCredential
            $credobject.KeyId = [guid]::NewGuid()
            $credobject.EndDate = (Get-Date).AddYears(10)
            $credobject.Value = $Key

            $myApp = New-AzureADApplication -DisplayName $application.DisplayName -IdentifierUris "https://localhost" -Homepage "https://sss.columbusit.com" -ReplyUrls "https://sss.columbusit.com:8080/Azure/CreatePSAppRegistrationSuccessPermissions" -RequiredResourceAccess $application.RequiredResourceAccess -PasswordCredentials $credobject
            
            Set-SQLEntConfig -Organization $Organization -AppID $myApp.AppId -AppSecret $key

            $Returnobject = [pscustomobject]@{
                Organization = $($Organization)
                TenantId     = $($Config.TenantID)
                Name         = $($application.DisplayName)
                KeySecret    = $($Key)
                AppId        = $($myApp.AppId)
                AdminUser    = $($Config.AdminUser)
                AdminPass    = $($Config.AdminPass)
            }
            $Returnobject
            <#
            write-output "App Key Secret: $($Key)"
            write-output "App ID: $($myApp.AppId)"
            Write-Output "Configuration has been updated"
            #>
        }
        else {
            throw "App already exist.."
        }
    }
}