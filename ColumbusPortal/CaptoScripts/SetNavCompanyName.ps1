[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]$Organization,

    [Parameter(Mandatory)]
    [string]$CompanyName,

    [switch]$NativeDatabase,

    [bool]$Force
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

Import-Module (Join-Path $PSScriptRoot "Capto")

$Config = Get-TenantConfig -TenantName $Organization

if($Config.Product.Name -eq "Legal"){
    if (-not ((Get-ADGroupMember -Server $Config.DomainFQDN -Identity $Config.LegalRoleGroupName).Name -contains $Config.UserRoleGroupName)) {
        throw "Tenant '$Organization' is not an Legal solution."
    }
elseif($Config.Product.Name -eq "AdvoPlus"){
        if (-not ((Get-ADGroupMember -Server $Config.DomainFQDN -Identity $Config.AdvoPlusRoleGroupName).Name -contains $Config.UserRoleGroupName)) {
            throw "Tenant '$Organization' is not an AdvoPlus solution."
        }
    }
}

$gpo = Get-GPO -Domain $Config.DomainFQDN -Name $Config.NewCustomerGpoName
$gpoPath = "\\$($Config.DomainFQDN)\SYSVOL\$($Config.DomainFQDN)\Policies\{{{0}}}" -f $gpo.Id

if($Config.Product.Name -eq "AdvoPlus"){
    $advoparams = @{
        TenantName     = $Organization
        CompanyName    = $CompanyName
        GPOPath        = $gpoPath
        NativeGPOName  = $Config.GroupPolicy.AdvoPlusNative.Name
        UsersOU        = $Config.UsersOU
        DomainName     = $Config.DomainFQDN
        Force          = $Force
    }
}

if($Config.Product.Name -eq "Legal"){
    $legalparams = @{
        TenantName     = $Organization
        CompanyName    = $CompanyName
        GPOPath        = $gpoPath
        UsersOU        = $Config.UsersOU
        DomainName     = $Config.DomainFQDN
        Force          = $Force
    }
}

if($Config.Product.Name -eq "AdvoPlus"){
    if ($NativeDatabase) {
        $advoparams.Add("NativeDatabaseServer", "$($Config.NativeDatabaseServer.Name):$($Config.NativeDatabaseServer.Port)")
    }
    else {
        $advoparams.Add("DatabaseServer", $Config.DatabaseServer.Name)
    }
}
if($Config.Product.Name -eq "Legal"){
    $legalparams.Add("DatabaseServer", $Config.DatabaseServer.Name)
}

if($Config.Product.Name -eq "AdvoPlus"){
    Update-AdvoPlusGpoSettings @advoparams
}
if($Config.Product.Name -eq "Legal"){
    Update-LegalGpoSettings @legalparams
}

$errors = @()

if (-not $force){
    if (-not $NativeDatabase -and $Config.Product.Name -eq "AdvoPlus") {
        $webserviceParams = @{
            TenantName  = $Config.Name
            CompanyName = $CompanyName 
            WebServicePath    = $Config.RepositoryServer.WebServicePath 
            WebServiceLogPath = $Config.RepositoryServer.WebServiceLogPath 
            LogWriter    = (Get-ADGroup -Server $Config.DomainFQDN -Identity $Config.AdvoPlusRepoLogsGroupName).SID
            ComputerName = $Config.RepositoryServer.Fqdn
        }

        try {
            New-AdvoPlusWebServiceInstance @webserviceParams
        }
        catch {
            Write-Error $_.ToString()
        }

        try {
            New-AdvoPlusMobileServerInstance -TenantName $Config.Name -CompanyName $CompanyName -ComputerName $Config.MobileServer.Fqdn
        }
        catch {
            Write-Error $_.ToString()
        }
    }
}

if ($force){
    if (-not $NativeDatabase -and $Config.Product.Name -eq "AdvoPlus") {
        $webserviceParams = @{
            TenantName  = $Config.Name
            CompanyName = $CompanyName 
            WebServicePath    = $Config.RepositoryServer.WebServicePath 
            WebServiceLogPath = $Config.RepositoryServer.WebServiceLogPath 
            LogWriter    = (Get-ADGroup -Server $Config.DomainFQDN -Identity $Config.AdvoPlusRepoLogsGroupName).SID
            ComputerName = $Config.RepositoryServer.Fqdn
            Force        = $Force
        }

        try {
            New-AdvoPlusWebServiceInstance @webserviceParams
        }
        catch {
            Write-Error $_.ToString()
        }

        try {
            New-AdvoPlusMobileServerInstance -TenantName $Config.Name -CompanyName $CompanyName -ComputerName $Config.MobileServer.Fqdn -Force $Force
        }
        catch {
            Write-Error $_.ToString()
        }
    }
}

if (-not $force){
    if (-not $NativeDatabase -and $Config.Product.Name -eq "Legal") {
        $webserviceParams = @{
            TenantName  = $Config.Name
            CompanyName = $CompanyName 
            WebServicePath    = $Config.RepositoryServer.WebServicePath 
            WebServiceLogPath = $Config.RepositoryServer.WebServiceLogPath 
            LogWriter    = (Get-ADGroup -Server $Config.DomainFQDN -Identity $Config.LegalRepoLogsGroupName).SID
            ComputerName = $Config.RepositoryServer.Fqdn
        }

        try {
            New-LegalWebServiceInstance @webserviceParams
        }
        catch {
            Write-Error $_.ToString()
        }

        try {
            New-LegalMobileServerInstance -TenantName $Config.Name -CompanyName $CompanyName -ComputerName $Config.MobileServer.Fqdn
        }
        catch {
            Write-Error $_.ToString()
        }
        try {
             # Configure Legal Nav Web service (CPO WEB 01)

            $LegalNAVWebserviceparams = @{
                TenantName       = $Config.Name
                ComputerName     = $Config.LegalWebServer.Fqdn
            }

            New-LegalNAVWebServiceInstance @LegalNAVWebserviceparams
        }
        catch {
            Write-Error $_.ToString()
        }
    }
}

if ($force){
    if (-not $NativeDatabase -and $Config.Product.Name -eq "Legal") {
        $webserviceParams = @{
            TenantName  = $Config.Name
            CompanyName = $CompanyName 
            WebServicePath    = $Config.RepositoryServer.WebServicePath 
            WebServiceLogPath = $Config.RepositoryServer.WebServiceLogPath 
            LogWriter    = (Get-ADGroup -Server $Config.DomainFQDN -Identity $Config.LegalRepoLogsGroupName).SID
            ComputerName = $Config.RepositoryServer.Fqdn
            Force        = $Force
        }

        try {
            New-LegalWebServiceInstance @webserviceParams
        }
        catch {
            Write-Error $_.ToString()
        }

        try {
            New-LegalMobileServerInstance -TenantName $Config.Name -CompanyName $CompanyName -ComputerName $Config.MobileServer.Fqdn -Force $Force
        }
        catch {
            Write-Error $_.ToString()
        }

        try {
             # Configure Legal Nav Web service (CPO WEB 01)
            $LegalNAVWebserviceparams = @{
                TenantName       = $Config.Name
                ComputerName     = $Config.LegalWebServer.Fqdn
                Force            = $true
            }

            New-LegalNAVWebServiceInstance @LegalNAVWebserviceparams
        }
        catch {
            Write-Error $_.ToString()
        }
    }
}