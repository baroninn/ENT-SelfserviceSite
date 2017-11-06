function Set-CloudAdminPassword {
    [Cmdletbinding()]
    param(
    [Parameter(Mandatory = $true)]
    [string]$Organization
    )
    
    Begin {

        Import-Module MSOnline > $null

        $Config = Get-SQLEntConfig -Organization $Organization
        
    }
    Process {

        if (!($Config.AdminUser -or $Config.AdminPass)) {
            throw "Either Tenant Admin User og Pass is missing from conf. Please update the customer configuration with this before continuing.."
        }

        $User             = "$($Config.AdminUser)"
        $Pass             = "$($Config.AdminPass)"
        $Credential       = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, ($Pass | ConvertTo-SecureString -AsPlainText -Force)

        try {
            Connect-MsolService -Credential $Credential > $null

            Set-MsolUserPassword -UserPrincipalName $($Config.AdminUser) -NewPassword "SYSop4$($Organization.ToLower())" -ForceChangePassword:$false
            Set-MsolUser -UserPrincipalName $($Config.AdminUser) -PasswordNeverExpires:$true

            Set-SQLEntConfig -Organization $Organization -AdminPass "SYSop4$($Organization.ToLower())"
        }
        catch {
            throw "$($_.exception)"
        }
        Write-Output "PasswordNeverExpires has been set, and the DB has been updated with the new default password."

    }
}