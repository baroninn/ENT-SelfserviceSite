[Cmdletbinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Organization,

    [Parameter(Mandatory)]
    [string]
    $UserPrincipalName
)

Import-Module (Join-Path $PSScriptRoot "Capto")

$obj = [pscustomobject]@{
    Organization               = $Organization
    UserPrincipalName          = $UserPrincipalName
    Name                       = "empty"
    ForwardingAddress          = "empty"
    DeliverToMailboxAndForward = $false
}

$mbx = Get-TenantMailbox -TenantName $Organization -Name $UserPrincipalName -Single

if ($mbx.ForwardingAddress -eq $null -and $mbx.ForwardingSmtpAddress -eq $null) {
    return $obj
}
else {
    if ($mbx.ForwardingAddress -ne $null) {
        try {
            $forwardingObject = Get-TenantMailContact -TenantName $Organization -Name $mbx.ForwardingAddress -Single
        }
        catch {
            $forwardingObject = Get-TenantMailbox -TenantName $Organization -Name $mbx.ForwardingAddress -Single
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