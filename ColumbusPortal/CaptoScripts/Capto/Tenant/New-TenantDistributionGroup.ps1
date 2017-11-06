function New-TenantDistributionGroup {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $PrimarySmtpAddress,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $ManagedBy,

        [Parameter(ValueFromPipelineByPropertyName)]
        [bool]
        $RequireSenderAuthentication=$true
    )

    Begin {
        $ErrorActionPreference = "Stop"
        Set-StrictMode -Version 2

        Import-Module (New-ExchangeProxyModule -Command "Enable-DistributionGroup", "Set-DistributionGroup")
    }
    Process {
        $TenantName = $TenantName.ToUpper()
        
        $Config = Get-TenantConfig -Name $TenantName
        
        $manager = Get-TenantMailbox -TenantName $TenantName -Name $ManagedBy

        Write-Verbose "Creating AD group '$Name'..."
        $distGroup = New-ADGroup -Name $Name -GroupCategory Distribution -GroupScope Universal -Path $Config.DistributionGroupsOU -Server $Config.DomainFQDN -PassThru    

        Wait-ADReplication -DistinguishedName $distGroup.DistinguishedName -DomainName $Config.DomainFQDN

        Write-Verbose "Enabling distribution group..."
        $newDistGroup = Enable-DistributionGroup -Identity $distGroup.DistinguishedName

        Write-Verbose "Setting PrimarySmtpAddress to '$PrimarySmtpAddress' and CustomAttribute1 to '$TenantName'..."
        $newDistGroup | Set-DistributionGroup -PrimarySmtpAddress $PrimarySmtpAddress -CustomAttribute1 $TenantName -EmailAddressPolicyEnabled $false -ManagedBy $manager.DistinguishedName

        if (-not $RequireSenderAuthentication) {
            Write-Verbose "Disabling RequireSenderAuthenticationEnabled..."
            $newDistGroup | Set-DistributionGroup -RequireSenderAuthenticationEnabled $false
        }
    }
}