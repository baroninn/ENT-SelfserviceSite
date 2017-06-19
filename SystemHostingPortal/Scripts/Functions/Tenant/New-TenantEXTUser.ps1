function New-TenantEXTUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Organization,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Password,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [string]$PrimarySmtpAddress,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [string]$DisplayName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [string]$Description,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName="User")]
        [string]$ExpirationDate
    )


    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        $Cred = Get-RemoteCredentials -Organization $Organization
    }
    Process {
        $Organization = $Organization.ToUpper()


        if ($PrimarySmtpAddress.IndexOf('@') -ne -1) {
            $alias  = $PrimarySmtpAddress.Substring(0, $PrimarySmtpAddress.IndexOf('@'))
            $domain = $PrimarySmtpAddress.Substring($PrimarySmtpAddress.IndexOf('@') + 1)
            if ($alias -eq $null -or $alias -eq '') {
                Write-Error "PrimarySmtpAddress '$PrimarySmtpAddress' does not have a valid alias."
            }
            elseif ($domain -eq $null -or $domain -eq '') {
                Write-Error "PrimarySmtpAddress '$PrimarySmtpAddress' does not have a valid domain."
            }
        }
        else {
            Write-Error "PrimarySmtpAddress '$PrimarySmtpAddress' is not a valid e-mail address."
        }

        $Config = Get-EntConfig -Organization $Organization -JSON

        $OrganizationDomains = @($Config.EmailDomains)
        if (-not ($OrganizationDomains.Where{$_.DomainName -eq "$domain"})) {
            Write-Error "Domain '$domain' was not found for the tenant '$Organization'."
        }

        # SAMAccountName must be 20 chars or less.
        $SAMAccountName = ($PrimarySmtpAddress.Split('@')[0])
        if ($SAMAccountName.Length -gt 20) {
            $SAMAccountName = $SAMAccountName.Substring(0, 19)
        }

        Write-Verbose "SAMAccountName: $SAMAccountName"

                                                                                                   
        $newUserParams = @{
            Name                  = "$DisplayName"
            Enabled               = $true
            SamAccountName        = $SAMAccountName
            DisplayName           = "$DisplayName - EXT"
            AccountPassword       = (ConvertTo-SecureString -String $Password -AsPlainText -Force)
            Path                  = $Config.CustomerOUDN
            UserPrincipalName     = $PrimarySmtpAddress
            EmailAddress          = $PrimarySmtpAddress
            Server                = $Config.DomainFQDN
            PassThru              = $null
            AccountExpirationDate = $ExpirationDate
            Description           = $Description
        }

        $newUser = New-ADUser @newUserParams -Credential $Cred

    }
}