function New-ExchangeProxyModule {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$Command,

        [Parameter(Mandatory)]
        [string]$Organization
    )

    $sessionName = 'ENTExchange'
    $Config      = Get-EntConfig -Organization $Organization
    $Cred        = Get-RemoteCredentials -Organization $Organization

    # Remove the module/session from this scope, to avoid it getting stuck in the users scope.
    Get-Module -Name "tmp_*" -ErrorAction SilentlyContinue | Remove-Module
    Get-PSSession -Name $sessionName -ErrorAction SilentlyContinue | Remove-PSSession

    if($Config.ExchangeServer -ne "null"){
        try {
            $returnModule = Import-PSSession -Session (New-PSsession -Name $sessionName -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$($Config.ExchangeServer)/Powershell" -Credential $cred) -CommandName $Command -AllowClobber
        }
        catch {
            throw $_
        }
    }

    return $returnModule
}
