function Get-TenantConfig {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('CustomAttribute1', 'Organization', 'Name')]
        [string]
        $TenantName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Server = 'hosting.capto.dk'
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }
    Process {
        try {
            $json = (Get-ADOrganizationalUnit -Server $Server -Identity "OU=$TenantName,OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk" -Properties adminDescription).adminDescription
            $obj = ConvertFrom-Json -InputObject $json
            $domain = (Get-TenantAcceptedDomain -TenantName $TenantName -Primary).DomainName
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