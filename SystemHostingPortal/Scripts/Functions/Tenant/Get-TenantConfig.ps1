function Get-TenantConfig {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('CustomAttribute1', 'Organization', 'Name')]
        [string]
        $Organization
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        $Config = Get-Content (Join-Path $PSScriptRoot "Functions\Config\$Organization\$Organization.txt") -Raw | ConvertFrom-Json
    }
    Process {
        try {

            if($obj -notlike "*TenantID365*"){

                if($obj.Product -eq 'ADVOPLUS'){
                New-TenantConfig -Name $TenantName -PrimarySmtpAddress $domain -FileServer $obj.FileServer.Name -FileServerDriveLetter $obj.FileServer.DriveLetter -AdvoPlusGpoSet $obj.AdvoPlus.GpoSet -Product $obj.Product
                }
                if($obj.Product -eq 'Member2015'){
                New-TenantConfig -Name $TenantName -PrimarySmtpAddress $domain -FileServer $obj.FileServer.Name -FileServerDriveLetter $obj.FileServer.DriveLetter -Product $obj.Product
                }
                if($obj.Product -eq 'LEGAL'){
                New-TenantConfig -Name $TenantName -PrimarySmtpAddress $domain -FileServer $obj.FileServer.Name -FileServerDriveLetter $obj.FileServer.DriveLetter -LegalGpoSet $obj.Legal.GpoSet -Product $obj.Product
                }
            }
            if($obj -like "*TenantID365*"){

                if($obj.Product -eq 'ADVOPLUS'){
                New-TenantConfig -Name $TenantName -PrimarySmtpAddress $domain -FileServer $obj.FileServer.Name -FileServerDriveLetter $obj.FileServer.DriveLetter -AdvoPlusGpoSet $obj.AdvoPlus.GpoSet -Product $obj.Product -TenantID $obj.TenantID365.ID -TenantAdmin $obj.TenantID365.Admin -TenantPass $obj.TenantID365.Pass
                }
                if($obj.Product -eq 'Member2015'){
                New-TenantConfig -Name $TenantName -PrimarySmtpAddress $domain -FileServer $obj.FileServer.Name -FileServerDriveLetter $obj.FileServer.DriveLetter -Product $obj.Product -TenantID $obj.TenantID365.ID -TenantAdmin $obj.TenantID365.Admin -TenantPass $obj.TenantID365.Pass
                }
                if($obj.Product -eq 'LEGAL'){
                New-TenantConfig -Name $TenantName -PrimarySmtpAddress $domain -FileServer $obj.FileServer.Name -FileServerDriveLetter $obj.FileServer.DriveLetter -LegalGpoSet $obj.Legal.GpoSet -Product $obj.Product -TenantID $obj.TenantID365.ID -TenantAdmin $obj.TenantID365.Admin -TenantPass $obj.TenantID365.Pass
                }
            }
        
        }
        catch {
             throw "Unable to get tenant configuration for $TenantName. Error: $_"
        }

    }
}