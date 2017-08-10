function Wait-MailboxCreation {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Identity
    )

    $mbxobjectFound = $false

    $startTime = [DateTime]::Now
    Write-Verbose "Waiting for mbx creation on exchange..."
    for ($i = 0; $i -lt 90; $i++) {
        $mbxobject = $null
        if ($Identity) {
            if ($i -eq 0) {
                Write-Verbose "mbx to find: $Identity"
            }
            try{$mbxobject = Get-Mailbox -Identity $Identity -ErrorAction SilentlyContinue}catch{}
        }


        if ($mbxobject -ne $null) {
            Write-Verbose ("Object found on exchange. Replication took {0:N0} seconds." -f ([DateTime]::Now - $startTime).TotalSeconds)
            $mbxobjectFound = $true
            break
        }
        else {
            if ( $i -gt 0 -and ($i % 10) -eq 0) {
                Write-Verbose ("Object not found yet. Waited for {0:N0} seconds..." -f ([DateTime]::Now - $startTime).TotalSeconds)
            }
            sleep 5
        }
    }

    if (-not $mbxobjectFound) {
        Write-Error "Object was never found" -ErrorAction 'Stop'
    }
}