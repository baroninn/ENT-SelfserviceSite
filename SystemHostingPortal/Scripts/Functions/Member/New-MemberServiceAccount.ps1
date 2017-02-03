function New-MemberServiceAccount {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Name,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$UserPrincipalName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Password
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0
    }

    Process {
        $Config = Get-TenantConfig -TenantName $TenantName

        $tmpServiceAccount = Get-ADUser -Server $Config.DomainFQDN -SearchBase $Config.Member.PrecreatedServiceAccountsOU -ResultSetSize 1 -Filter "Name -like '_svcprecreated*'"

        if (-not $tmpServiceAccount) {
            Write-Error "No precreated service account was found."
        }

        $tmpServiceAccount = $tmpServiceAccount | Move-ADObject -TargetPath $Config.ServiceAccountsOU -Server $Config.DomainFQDN -PassThru
        $tmpServiceAccount | Set-ADAccountPassword -NewPassword (ConvertTo-SecureString -String $Password -AsPlainText -Force) -Server $Config.DomainFQDN
        $tmpServiceAccount = $tmpServiceAccount | Set-ADUser -UserPrincipalName $UserPrincipalName -SamAccountName $Name -Clear "Description" -Enabled $true -PassThru -Server $Config.DomainFQDN
        $tmpServiceAccount = $tmpServiceAccount | Rename-ADObject -NewName $Name -PassThru -Server $Config.DomainFQDN

        Add-ADGroupMember -Identity $Config.ReadAccessGroupName -Members $tmpServiceAccount -Server $Config.DomainFQDN
    }

}