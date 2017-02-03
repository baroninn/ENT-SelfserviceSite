function Connect-O365 {
    [Cmdletbinding()]
    param (
        [string]$Organization,
        [string]$Command
    )
    
    $Config = Get-TenantConfig -TenantName $Organization


    Import-Module MSOnline -Cmdlet Connect-MsolService
    $Username = $Config.TenantID365.Admin
    $password = ConvertTo-SecureString $Config.Tenantid365.Pass -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential $Username, $password

    Connect-MsolService –Credential $Credentials

    if ((Get-MsolAccountSku).AccountSkuId -like "*ENTERPRISEPACK") {
    
        Import-PSSession -Session (New-PSSession -ConfigurationName Microsoft.Exchange `
                                                 -ConnectionUri "https://outlook.office365.com/powershell-liveid/" `
                                                 -Credential $credentials `
                                                 -Authentication "Basic" `
                                                 -AllowRedirection) -CommandName $Command
        }


}