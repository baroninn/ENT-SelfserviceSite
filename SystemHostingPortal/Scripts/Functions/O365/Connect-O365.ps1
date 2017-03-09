function Connect-O365 {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,
        [string]$Command
    )
    
    $Config = Get-EntConfig -Organization $Organization


    Import-Module MSOnline -Cmdlet Connect-MsolService
    $Username = $Config.AdminUser365
    $password = ConvertTo-SecureString $Config.AdminPass365 -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential $Username, $password

    # Remove the module/session from this scope, to avoid it getting stuck in the users scope.
    Get-Module -Name "tmp_*" -ErrorAction SilentlyContinue | Remove-Module
    Get-PSSession -Name "Office365" -ErrorAction SilentlyContinue | Remove-PSSession

    Connect-MsolService –Credential $Credentials | Out-Null

    if ((Get-MsolAccountSku).AccountSkuId -like "*ENTERPRISEPACK") {
    
        Import-PSSession -Session (New-PSSession -ConfigurationName Microsoft.Exchange `
                                                 -ConnectionUri "https://outlook.office365.com/powershell-liveid/" `
                                                 -Credential $credentials `
                                                 -Authentication "Basic" `
                                                 -AllowRedirection) -DisableNameChecking -AllowClobber | Out-Null
        }

}