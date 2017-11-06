function New-TenantDistributionGroup {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Organization,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $PrimarySmtpAddress,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $ManagedBy,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        $RequireSenderAuthentication
    )

    Begin {

        $ErrorActionPreference = "Stop"
        Import-Module ActiveDirectory

        $Config = Get-SQLEntConfig -Organization $Organization

        $Cred  = Get-RemoteCredentials -Organization $Organization
    }

    Process {

        $Organization = $Organization.ToUpper()
        
        if ($managedby -ne '') {

            try{
                $manager = Get-ADUser -Identity ($managedby -split '@')[0] -Server $Config.DomainFQDN -Credential $Cred
                $distGroup = New-ADGroup -Name $Name -ManagedBy $manager -GroupCategory Distribution -GroupScope Universal -Path $Config.CustomerOUDN -Server $Config.DomainFQDN -Credential $Cred -PassThru
            }
            catch{
                throw $_
            }
        }
        else{
            $distGroup = New-ADGroup -Name $Name -GroupCategory Distribution -GroupScope Universal -Path $Config.CustomerOUDN -Server $Config.DomainFQDN -Credential $Cred -PassThru
        }

        Write-Verbose "Creating AD group '$Name'..."

        try {
            Set-ADGroup -Identity $distGroup.DistinguishedName -DisplayName $name -replace @{mail=$PrimarySmtpAddress} -Server $Config.DomainFQDN -Credential $Cred
        }
        catch {
            throw $_
        }

        if (-not [string]::IsNullOrWhiteSpace($Config.ExchangeServer)) {

            Import-Module (New-ExchangeProxyModule -Organization $Organization -Command "Enable-DistributionGroup", "Set-DistributionGroup")

            Write-Verbose "Enabling distribution group..."
            $newDistGroup = Enable-DistributionGroup -Identity $distGroup.DistinguishedName

            Write-Verbose "Setting PrimarySmtpAddress to '$PrimarySmtpAddress'..."
            $newDistGroup | Set-DistributionGroup -PrimarySmtpAddress $PrimarySmtpAddress -EmailAddressPolicyEnabled $false -ManagedBy $manager.DistinguishedName
            
            if ($RequireSenderAuthentication) {
                Write-Verbose "Disabling RequireSenderAuthenticationEnabled..."
                $newDistGroup | Set-DistributionGroup -RequireSenderAuthenticationEnabled $false
            }
        }
        else {

            if ($RequireSenderAuthentication) {
                Set-ADGroup -Identity $distGroup.DistinguishedName -DisplayName $name -replace @{msExchRequireAuthToSendTo=$False} -Server $Config.DomainFQDN -Credential $Cred
            }
            else {
                Set-ADGroup -Identity $distGroup.DistinguishedName -DisplayName $name -replace @{msExchRequireAuthToSendTo=$True} -Server $Config.DomainFQDN -Credential $Cred
            }
        }

        if ($Config.AADsynced -eq 'true') {
            Start-Dirsync -Organization $Organization -Policy 'delta'
            Write-Output "Directory sync has been initiated, because the customer has Office365."
        }
    }
}