[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]
    $UserPrincipalName
)

Import-Module (Join-Path $PSScriptRoot "Functions")

$obj = [pscustomobject]@{
    Organization               = $Organization
    UserPrincipalName          = $UserPrincipalName
    Name                       = "empty"
    ForwardingAddress          = "empty"
    DeliverToMailboxAndForward = $false
}

$mbx = Get-TenantMailbox -Organization $Organization -Name $UserPrincipalName -Single

if ($mbx.ForwardingAddress -eq $null -and $mbx.ForwardingSmtpAddress -eq $null) {
    return $obj
}
else {
    if ($mbx.ForwardingAddress -ne $null) {
        try {
            #$forwardingObject = Get-TenantMailContact -Organization $Organization -Name $mbx.ForwardingAddress -Single
            $forwardingObject = Get-TenantMailbox -Organization $Organization -Name $mbx.ForwardingAddress -Single -forwardingaddress
            #throw $forwardingObject
        }
        catch {
            $forwardingObject = Get-TenantMailbox -Organization $Organization -Name $mbx.ForwardingAddress -Single
        }

    }
    else {
        $forwardingObject = [pscustomobject]@{ 
            DisplayName        = $mbx.ForwardingSmtpAddress.Substring(5)
            PrimarySmtpAddress = $mbx.ForwardingSmtpAddress.Substring(5)
        }
    }

    if ($forwardingObject -ne $null) {
        $obj.Name                       = $forwardingObject.DisplayName
        $obj.ForwardingAddress          = $forwardingObject.PrimarySmtpAddress
        $obj.DeliverToMailboxAndForward = $mbx.DeliverToMailboxAndForward

        return $obj
    }
    else {
        Write-Error "Unable to retrieve information about the receiver."
    }
}