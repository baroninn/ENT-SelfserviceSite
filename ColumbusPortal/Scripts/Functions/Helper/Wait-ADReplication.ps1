function Wait-ADReplication {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ParameterSetName="UPN")]
        [string]$UPN,

        [Parameter(Mandatory, ParameterSetName="DistinguishedName")]
        [string]$DistinguishedName,

        [Parameter(Mandatory, ParameterSetName="GPOGuid")]
        [string]$GPOGuid,

        [Parameter(Mandatory)]
        [psobject]$Config,

        [Parameter(Mandatory)]
        [pscredential]$Cred
    )

    $dcs = Get-ADDomainController -Credential $Cred -Server $config.DomainFQDN -Filter 'HostName -notlike "ASG2K8B1V001*"' -ErrorAction 'Stop'

    foreach ($dc in $dcs) {
        $adobjectFound = $false

        $startTime = [DateTime]::Now
        Write-Verbose "Waiting for AD replication on $($dc.Hostname)..."
        for ($i = 0; $i -lt 90; $i++) {
            $adobject = $null
            if ($UPN) {
                if ($i -eq 0) {
                    Write-Verbose "UPN to find: $UPN"
                }
                $adobject = Get-ADObject -Server $dc.HostName -Credential $Cred -LDAPFilter "(userPrincipalName=$UPN)"
            }
            elseif ($DistinguishedName) {
                if ($i -eq 0) {
                    Write-Verbose "DistinguishedName to find: $DistinguishedName"
                }
                $adobject = Get-ADObject -Server $dc.HostName -Credential $Cred -LDAPFilter "(distinguishedName=$DistinguishedName)"
            }
            elseif ($GPOGuid) {
                if ($i -eq 0) {
                    Write-Verbose "GPOGuid to find: $GPOGuid"
                }
                $adobject = Get-ADObject -Server $dc.HostName -Credential $Cred -LDAPFilter "(name={$GPOGuid})"
            }

            if ($adobject -ne $null) {
                Write-Verbose ("Object found on $($dc.Hostname). Replication took {0:N0} seconds." -f ([DateTime]::Now - $startTime).TotalSeconds)
                $adobjectFound = $true
                break
            }
            else {
                if ( $i -gt 0 -and ($i % 10) -eq 0) {
                    Write-Verbose ("Object not found yet. Waited for {0:N0} seconds..." -f ([DateTime]::Now - $startTime).TotalSeconds)
                }
                sleep 1
            }
        }

        if (-not $adobjectFound) {
            Write-Error "Object was never found on $($dc.HostName)" -ErrorAction 'Stop'
        }
    }
}