function New-ExchangeProxyModule {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$Command,

        [Parameter(Mandatory)]
        [string]$Organization
    )

    $sessionName = $Organization
    $Config      = Get-EntConfig -Organization $Organization
    $Cred        = Get-RemoteCredentials -Organization $Organization


    # Remove the module/session from this scope, to avoid it getting stuck in the users scope.
    Get-Module -Name "tmp_*" | Remove-Module
    $Session = Get-PSSession -Name $sessionName -ErrorAction SilentlyContinue

    if ($Session -ne $null) {
        $returnModule = Import-PSSession -Session $Session -CommandName $Command -AllowClobber
    }
    else {
        try {
            Get-PSSession | where{$_.ConfigurationName -eq "Microsoft.Exchange"} | Remove-PSSession
        }
        catch {
            "Removal of existing sessions failed with: $_"
        }
        

        if($Config.ExchangeServer -ne "null"){
            try {
                $returnModule = Import-PSSession -Session (New-PSsession -Name $sessionName -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$($Config.ExchangeServer)/Powershell" -Credential $cred) -CommandName $Command -AllowClobber
            }
            catch {
                throw $_
            }
        }

        if ($Config.TenantID365 -ne "null" -and $Config.ExchangeServer -eq "null") {
            try {
                ## Create O365 credential object
                $Username = $Config.AdminUser365
                $password = ConvertTo-SecureString $Config.AdminPass365 -AsPlainText -Force
                $Credentials = New-Object System.Management.Automation.PSCredential $Username, $password

                $returnModule = Import-PSSession -Session (New-PSSession -ConfigurationName Microsoft.Exchange -Name $sessionName -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $Credentials -Authentication "Basic") -DisableNameChecking -CommandName $Command -AllowClobber
            }
            catch {
                throw $_
            }
        }
    }

    # Remove the module from this scope, to avoid it getting stuck in the users scope.
    #Get-Module -Name "tmp_*" | Remove-Module
    return $returnModule
}
