function New-TenantMailboxPermissionGroup {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('CustomAttribute1', 'Organization')]
        [string]
        $TenantName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $UserPrincipalName,

        [Parameter(Mandatory)]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [ValidateSet("FullAccess","SendAs")]
        [string]
        $Permission,

        [Parameter(Mandatory)]
        [string]
        $Path,

        [string]
        $Server = 'hosting.capto.dk'
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Import-Module (New-ExchangeProxyModule -Command "Add-MailboxPermission", "Add-ADPermission")
    }

    Process {
        $mbx = Get-TenantMailbox -TenantName $TenantName -Name $UserPrincipalName -Single

        $group = New-ADGroup -Name $Name -GroupCategory Security -GroupScope Universal -Path $Path -Server $Server -PassThru
        Wait-ADReplication -DomainName $Server -DistinguishedName $group.DistinguishedName

        switch ($Permission) {
            "FullAccess" {
                $null = $mbx | Add-MailboxPermission -AccessRights FullAccess -User $group.DistinguishedName -Confirm:$false
            }
            "SendAs" {
                $null = $mbx | Add-ADPermission -User $group.DistinguishedName -ExtendedRights 'Send As' -Confirm:$false 
            }
            Default {
                Write-Error "Unknown permission '$Permission'."
            }
        }
    }
}