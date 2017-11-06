function Connect-O365 {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization,
        [string]$Command
    )
    
    $Config = Get-TenantConfig -TenantName $Organization

    if ($Config.TenantID365.Admin -like "") {
        Throw "Office365 not configured for the customer"
    }


    Import-Module MSOnline -Cmdlet Connect-MsolService
    $Username = $Config.TenantID365.Admin
    $password = ConvertTo-SecureString $Config.Tenantid365.Pass -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential $Username, $password

    Connect-MsolService –Credential $Credentials | Out-Null

    try{

        if ((Get-MsolAccountSku).AccountSkuId -like "*ENTERPRISEPACK") {
    
            Import-PSSession -Session (New-PSSession -ConfigurationName Microsoft.Exchange `
                                                     -ConnectionUri "https://outlook.office365.com/powershell-liveid/" `
                                                     -Credential $credentials `
                                                     -Authentication "Basic" `
                                                     -AllowRedirection) -DisableNameChecking -AllowClobber | Out-Null
        }

    }catch {
        Write-Verbose "Accountsku not found. Error: $_"
    }

    Get-PSSession | where{$_.ComputerName -like "Outlook*"} | Remove-PSSession
}