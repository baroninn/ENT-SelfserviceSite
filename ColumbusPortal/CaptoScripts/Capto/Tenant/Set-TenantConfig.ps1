function Set-TenantConfig {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('CustomAttribute1', 'Organization', 'Name')]
        [string]
        $TenantName,

        [string]
        $FileServer,

        [string]
        $FileServerDriveLetter,

        [string]
        $TenantID365,

        [string]
        $TenantAdmin,

        [string]
        $TenantPass,

        [bool]
        $AdvoPlusGpoSet,

        [bool]
        $LegalGpoSet,

        [Parameter(Mandatory)]
        [string]
        [ValidateSet("AdvoPlus", "Member2015", "Legal")]
        $Product,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Server = 'hosting.capto.dk'
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }
    Process {

        $ou = "OU=$TenantName,OU=Customer,OU=SYSTEMHOSTING,DC=hosting,DC=capto,DC=dk"
        $json = (Get-ADOrganizationalUnit -Server $Server -Identity $ou -Properties adminDescription).adminDescription
        $newObj = New-TenantConfigObject

        if ($json -ne $null -and $AdvoPlusGpoSet) {
            $obj = ConvertFrom-Json -InputObject $json
            
            $newObj.FileServer.Name        = $obj.FileServer.Name
            $newObj.FileServer.DriveLetter = $obj.FileServer.DriveLetter

            if (-not $PSBoundParameters.ContainsKey('AdvoPlusGpoSet')) {
                $newObj.AdvoPlus.GpoSet = $obj.AdvoPlus.GpoSet
            }
        }
        if ($json -ne $null -and $LegalGpoSet) {
            $obj = ConvertFrom-Json -InputObject $json
            
            $newObj.FileServer.Name        = $obj.FileServer.Name
            $newObj.FileServer.DriveLetter = $obj.FileServer.DriveLetter

            if (-not $PSBoundParameters.ContainsKey('LegalGpoSet')) {
                $newObj.Legal.GpoSet = $obj.Legal.GpoSet
            }
        }
               
        if ($FileServer) {
            $newObj.FileServer.Name = $FileServer
        }

        if ($TenantID365) {
            $newObj.TenantID365.ID    = $TenantID365
            $newObj.TenantID365.Admin = $TenantAdmin
            $newObj.TenantID365.Pass  = $TenantPass
        }

        if ($FileServerDriveLetter) {
            $newObj.FileServer.DriveLetter = $FileServerDriveLetter
        }
        if ($PSBoundParameters.ContainsKey('AdvoPlusGpoSet')) {
            $newObj.AdvoPlus.GpoSet = $AdvoPlusGpoSet
        }
        if ($PSBoundParameters.ContainsKey('LegalGpoSet')) {
            $newObj.Legal.GpoSet = $LegalGpoSet
        }
        
        $newObj.Product = $Product

        $newJson = ConvertTo-Json -InputObject $newObj -Compress
        Set-ADOrganizationalUnit -Replace @{adminDescription=$newJson.ToString()} -Identity $ou -Server $Server
    }
}

function New-TenantConfigObject {
    [Cmdletbinding()]
    param ()

    [pscustomobject]@{
        FileServer = [pscustomobject]@{
            Name        = $null
            DriveLetter = $null
        }
        AdvoPlus = [pscustomobject]@{
            GpoSet = $false
        }
        Legal = [pscustomobject]@{
            GpoSet = $false
        }
        TenantID365 = [pscustomobject]@{
            ID    = $null
            Admin = $null
            Pass  = $null
        }

        Product = $null
    }
}