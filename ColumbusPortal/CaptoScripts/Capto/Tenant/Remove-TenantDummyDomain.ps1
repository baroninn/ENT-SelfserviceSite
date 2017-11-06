function Remove-TenantDummyDomain {
    [Cmdletbinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]
        $TenantName
    )

    Begin {
        $ErrorActionPreference = 'Stop'
        Set-StrictMode -Version 2.0

        Import-Module (New-ExchangeProxyModule -Command 'Get-EmailAddressPolicy', 'Set-EmailAddressPolicy', 'Set-Mailbox', 'New-AcceptedDomain', 'Remove-AcceptedDomain', 'Set-AcceptedDomain')
    }
    Process {
        $dummyDomains = @(Get-TenantAcceptedDomain -TenantName $TenantName | where DomainName -like 'dummy.*')

        if ($dummyDomains.Count -eq 0) {
            Write-Error "No dummy domains found for tenant '$TenantName'."
        }

        foreach ($domain in $dummyDomains) {
            $newDomain = $domain.DomainName.Substring(6).ToLower()
            $tempName = "$($domain.Name.Replace('dummy.', '')) -DUMMYTEMP"

            Write-Verbose "Adding temporary accepted domain for $newDomain"
            $null = New-AcceptedDomain -Name $tempName -DomainName $newDomain -DomainType Authoritative
            Write-Output "Added AcceptedDomain '$newDomain' with name '$tempName'"
        }
        
        $eap = @(Get-EmailAddressPolicy -Identity $TenantName)
        if ($eap.Count -eq 0) {
            Write-Error "No EmailAddressPolicy found for $TenantName"
        }
        elseif ($eap.Count -gt 1) {
            Write-Error "Tenant '$TenantName' it too ambigous ($($eap.Count) results)."
        }
        $eap = $eap[0]

        for ($i = $eap.EnabledEmailAddressTemplates.Count - 1; $i -ge 0; $i--) {
            $address = $eap.EnabledEmailAddressTemplates[$i]
            if ($address -like "smtp:%m@dummy.*") {
                $newAddress = $address.Replace('@dummy.', '@')
                
                Write-Verbose "Changing $address to $newAddress"
                $null = $eap.EnabledEmailAddressTemplates.Add($newAddress)
                $null = $eap.EnabledEmailAddressTemplates.Remove($address)
                Write-Output "Changed '$address' to '$newAddress' in EmailAddressPolicy"
                
            }
        }

        $eap | Set-EmailAddressPolicy -EnabledEmailAddressTemplates $eap.EnabledEmailAddressTemplates
        Write-Output "Committed changes to EmailAddressPolicy"

        foreach ($domain in $dummyDomains) {
            Write-Verbose "Removing dummy domain '$domain'"
            $domain | Remove-AcceptedDomain -Confirm:$false
            Write-Output "Removed AcceptedDomain '$domain'"
        }

        $newDomains = @(Get-TenantAcceptedDomain -TenantName $TenantName)

        foreach ($domain in $newDomains) {
            $newName = $domain.Name.Replace('-DUMMYTEMP', '').Trim()
            if ($newName -ne $domain.Name) {
                Write-Verbose "Setting AcceptedDomain Name from '$($domain.Name)' to '$newName'"
                $domain | Set-AcceptedDomain -Name $newName
                Write-Output "Renamed AcceptedDomain '$($domain.Name)' to '$newName'"
            }
        }

        $mbxs = Get-TenantMailbox -TenantName $TenantName
        foreach ($mbx in $mbxs) {
            $primaryAddress = $null

            for ($i = $mbx.EmailAddresses.Count - 1; $i -ge 0; $i--) {
                $address = $mbx.EmailAddresses[$i]
                if ($address -like "smtp:*@dummy.*") {
                    $newAddress = $address.Replace('@dummy.', '@')
                
                    Write-Verbose "Changing $address to $newAddress"
                    $null = $mbx.EmailAddresses.Add($newAddress)
                    $null = $mbx.EmailAddresses.Remove($address)
                    Write-Output "Changed '$address' to '$newAddress'"

                    if ($newAddress -clike "SMTP:*") {
                        $primaryAddress = $newAddress.Substring(5) # Remove 'SMTP:' from string
                        Write-Verbose "Primary SMTP is $primaryAddress"
                        Write-Output "Primary SMTP is $primaryAddress"
                    }
                }
            }

            if ($primaryAddress) {
                $mbx | Set-Mailbox -UserPrincipalName $primaryAddress -EmailAddresses $mbx.EmailAddresses
            }
            else {
                $mbx | Set-Mailbox -EmailAddresses $mbx.EmailAddresses
            }
            Write-Output "Committed changes to '$($mbx.DisplayName)'"
        }

        Write-Output "Done"
    }
}