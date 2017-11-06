function Connect-MSOnline {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Organization
    )
    
    $Config = Get-SQLEntConfig -Organization $Organization


    Import-Module MSOnline -Cmdlet Connect-MsolService
    $Username = $Config.AdminUser
    $password = ConvertTo-SecureString $Config.AdminPass -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential $Username, $password

    # Remove the module/session from this scope, to avoid it getting stuck in the users scope.
    # Important to keep the Exchange module imported, as it will only be the session that will change.
    #Get-PSSession -Name "Office365" -ErrorAction SilentlyContinue | Remove-PSSession
    try {
        Connect-MsolService –Credential $Credentials
    }
    catch {
        throw $_
    }

    # Remove the module from this scope, to avoid it getting stuck in the users scope.

    Get-Module -Name "MSOnline" -ErrorAction SilentlyContinue | Remove-Module

}