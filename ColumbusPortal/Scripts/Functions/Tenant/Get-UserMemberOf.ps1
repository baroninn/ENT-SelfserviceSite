function Get-UserMemberOf {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Organization,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$UserPrincipalName
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        $Config = Get-SQLENTConfig -Organization $Organization
        $Cred = Get-RemoteCredentials -Organization $Organization

    }
    Process {
        $gm = @(Get-ADPrincipalGroupMembership -Credential $Cred -Identity $UserPrincipalName.Split('@')[0] -Server $config.DomainFQDN | select -ExpandProperty name)
        
        return $gm
    }

    End {
    }
}